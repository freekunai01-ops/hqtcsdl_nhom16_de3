/**
 * QLDSV_HTC - Client-side JavaScript
 * Inspired by Figma Design UI (DataGrid pattern)
 */

// ===== TABLE ROW SELECTION =====
function initTableSelection(tableId, formPrefix) {
    var table = document.getElementById(tableId);
    if (!table) return;
    var rows = table.querySelectorAll('tbody tr');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            // Deselect all
            rows.forEach(function(r) { r.classList.remove('selected'); });
            // Select clicked
            this.classList.add('selected');
            // Populate form fields from row data attributes
            var cells = this.querySelectorAll('td');
            var inputs = document.querySelectorAll('[data-field]');
            inputs.forEach(function(input) {
                var field = input.getAttribute('data-field');
                var cell = row.querySelector('[data-col="' + field + '"]');
                if (cell) {
                    input.value = cell.textContent.trim();
                }
            });
            // Set action to update
            var actionField = document.getElementById(formPrefix + 'Action');
            if (actionField) actionField.value = 'update';
            // Disable primary key field on update
            var pkField = document.getElementById(formPrefix + 'PK');
            if (pkField) pkField.readOnly = true;
        });
    });
}

// ===== COLUMN SORT (from Figma DataGrid pattern) =====
// Click vào th[data-sort-key] để sort ASC/DESC, hiện icon ▲▼⇅
function initColumnSort(tableId) {
    var table = document.getElementById(tableId);
    if (!table) return;

    var currentSortKey = null;
    var currentSortDir = 'asc';

    var headers = table.querySelectorAll('thead th[data-sort-key]');
    headers.forEach(function(th) {
        // Thêm icon sort mặc định (⇅)
        var icon = document.createElement('span');
        icon.className = 'sort-icon';
        icon.textContent = ' ⇅';
        th.appendChild(icon);
        th.style.cursor = 'pointer';
        th.classList.add('sortable-th');

        th.addEventListener('click', function() {
            var key = this.getAttribute('data-sort-key');
            var colIndex = parseInt(this.getAttribute('data-sort-col'), 10);

            // Toggle sort direction
            if (currentSortKey === key) {
                currentSortDir = currentSortDir === 'asc' ? 'desc' : 'asc';
            } else {
                currentSortKey = key;
                currentSortDir = 'asc';
            }

            // Reset all sort icons
            headers.forEach(function(h) {
                h.querySelector('.sort-icon').textContent = ' ⇅';
                h.classList.remove('sort-active');
            });

            // Set active icon
            this.querySelector('.sort-icon').textContent = currentSortDir === 'asc' ? ' ▲' : ' ▼';
            this.classList.add('sort-active');

            // Sort tbody rows
            var tbody = table.querySelector('tbody');
            var rows = Array.from(tbody.querySelectorAll('tr'));

            rows.sort(function(a, b) {
                var cellA = a.cells[colIndex];
                var cellB = b.cells[colIndex];
                if (!cellA || !cellB) return 0;

                var valA = (cellA.getAttribute('data-sort-value') || cellA.textContent).trim();
                var valB = (cellB.getAttribute('data-sort-value') || cellB.textContent).trim();

                // Numeric comparison if both are numbers
                var numA = parseFloat(valA);
                var numB = parseFloat(valB);
                if (!isNaN(numA) && !isNaN(numB)) {
                    return currentSortDir === 'asc' ? numA - numB : numB - numA;
                }

                // Vietnamese locale string comparison
                var cmp = valA.localeCompare(valB, 'vi', { numeric: true, sensitivity: 'base' });
                return currentSortDir === 'asc' ? cmp : -cmp;
            });

            // Re-append sorted rows
            rows.forEach(function(row) {
                tbody.appendChild(row);
            });

            // Update display page (which also handles zebra stripes and pagination)
            displayTablePage(tableId);
        });
    });
}

// ===== TABLE SEARCH / FILTER WITH COLUMN AUTOFILTERS =====
window.activeTableFilters = {};

function initTableSearch(tableId, searchInputId) {
    applyTableFilters(tableId);
}

window.tableCurrentPages = {};
window.tablePageSize = 8;
window.tablePageNeedsSync = {};

function initColumnFilters(tableId) {
    var table = document.getElementById(tableId);
    if (!table) return;

    window.activeTableFilters[tableId] = {};
    window.tableCurrentPages[tableId] = 1;
    window.tablePageNeedsSync[tableId] = true;

    var headers = table.querySelectorAll('thead th[data-sort-key]');
    headers.forEach(function(th) {
        var colIndex = parseInt(th.getAttribute('data-sort-col'), 10);
        if (isNaN(colIndex)) return;

        // Create the filter trigger element
        var filterBtn = document.createElement('span');
        filterBtn.className = 'col-filter-btn';
        filterBtn.innerHTML = '<i class="fas fa-filter"></i>';
        filterBtn.setAttribute('data-col-index', colIndex);

        // Append to the header
        th.appendChild(filterBtn);

        // Click handler to open dropdown
        filterBtn.addEventListener('click', function(e) {
            e.stopPropagation(); // Avoid triggering sort
            openFilterDropdown(tableId, colIndex, this);
        });
    });

    // Run initial page display
    displayTablePage(tableId);
}

function openFilterDropdown(tableId, colIndex, triggerBtn) {
    closeAllFilterDropdowns();

    var table = document.getElementById(tableId);
    if (!table) return;

    // Collect unique values from the column
    var uniqueValues = new Set();
    var tbodyRows = table.querySelectorAll('tbody tr');
    tbodyRows.forEach(function(row) {
        // Skip empty table messages or loading rows
        if (row.cells.length === 1 && (row.cells[0].getAttribute('colspan') || 0) > 3) return;
        
        var cell = row.cells[colIndex];
        if (cell) {
            var val = (cell.getAttribute('data-sort-value') || cell.textContent).trim();
            if (val !== undefined && val !== null) {
                uniqueValues.add(val);
            }
        }
    });

    var sortedVals = Array.from(uniqueValues).sort(function(a, b) {
        var numA = parseFloat(a);
        var numB = parseFloat(b);
        if (!isNaN(numA) && !isNaN(numB)) return numA - numB;
        return a.localeCompare(b, 'vi', { numeric: true });
    });

    // Create dropdown element
    var dropdown = document.createElement('div');
    dropdown.className = 'col-filter-dropdown';
    dropdown.id = 'activeColFilterDropdown';

    var html = '';
    html += '<div class="col-filter-search-wrapper">';
    html += '  <i class="fas fa-search"></i>';
    html += '  <input type="text" class="col-filter-search" placeholder="Tìm giá trị...">';
    html += '</div>';

    html += '<div class="col-filter-list">';
    html += '  <label class="col-filter-item select-all-item">';
    html += '    <input type="checkbox" class="cb-select-all" checked> <span>(Chọn tất cả)</span>';
    html += '  </label>';

    var prevFilters = window.activeTableFilters[tableId][colIndex] || [];

    sortedVals.forEach(function(val) {
        var isChecked = prevFilters.length === 0 || prevFilters.indexOf(val) !== -1;
        html += '  <label class="col-filter-item val-item">';
        html += '    <input type="checkbox" value="' + val.replace(/"/g, '&quot;') + '"' + (isChecked ? ' checked' : '') + '> <span>' + val + '</span>';
        html += '  </label>';
    });
    html += '</div>';

    html += '<div class="col-filter-actions">';
    html += '  <button class="btn-clear">Xóa lọc</button>';
    html += '  <button class="btn-apply">Lọc</button>';
    html += '</div>';

    dropdown.innerHTML = html;
    document.body.appendChild(dropdown);

    // Prevent wheel scroll inside dropdown from closing it
    dropdown.addEventListener('wheel', function(e) {
        e.stopPropagation();
    }, { passive: true });

    // Position the dropdown below the filter button
    var rect = triggerBtn.getBoundingClientRect();
    var dropdownLeft = rect.left + window.scrollX;
    var dropdownTop = rect.bottom + window.scrollY + 2;

    dropdown.style.left = dropdownLeft + 'px';
    dropdown.style.top = dropdownTop + 'px';

    var dropdownRect = dropdown.getBoundingClientRect();
    if (dropdownRect.right > window.innerWidth) {
        dropdown.style.left = (window.innerWidth - dropdownRect.width - 10) + 'px';
    }

    // Inside dropdown interactive handlers
    var searchInput = dropdown.querySelector('.col-filter-search');
    var valItems = dropdown.querySelectorAll('.val-item');
    var cbSelectAll = dropdown.querySelector('.cb-select-all');
    var checkboxes = dropdown.querySelectorAll('.val-item input[type="checkbox"]');
    var btnApply = dropdown.querySelector('.btn-apply');
    var btnClear = dropdown.querySelector('.btn-clear');

    searchInput.addEventListener('input', function() {
        var query = this.value.toLowerCase().trim();
        valItems.forEach(function(item) {
            var text = item.textContent.toLowerCase();
            item.style.display = text.indexOf(query) !== -1 ? 'flex' : 'none';
        });
    });

    cbSelectAll.addEventListener('change', function() {
        var isChecked = this.checked;
        checkboxes.forEach(function(cb) {
            if (cb.parentNode.style.display !== 'none') {
                cb.checked = isChecked;
            }
        });
    });

    checkboxes.forEach(function(cb) {
        cb.addEventListener('change', function() {
            var allChecked = true;
            checkboxes.forEach(function(c) {
                if (!c.checked) allChecked = false;
            });
            cbSelectAll.checked = allChecked;
        });
    });

    btnApply.addEventListener('click', function() {
        var checkedVals = [];
        var totalCheckboxes = checkboxes.length;
        var checkedCount = 0;

        checkboxes.forEach(function(cb) {
            if (cb.checked) {
                checkedVals.push(cb.value);
                checkedCount++;
            }
        });

        if (checkedCount === totalCheckboxes || checkedCount === 0) {
            delete window.activeTableFilters[tableId][colIndex];
            triggerBtn.classList.remove('filter-active');
        } else {
            window.activeTableFilters[tableId][colIndex] = checkedVals;
            triggerBtn.classList.add('filter-active');
        }

        applyTableFilters(tableId);
        closeAllFilterDropdowns();
    });

    btnClear.addEventListener('click', function() {
        delete window.activeTableFilters[tableId][colIndex];
        triggerBtn.classList.remove('filter-active');
        applyTableFilters(tableId);
        closeAllFilterDropdowns();
    });

    setTimeout(function() {
        document.addEventListener('mousedown', outsideClickListener);
    }, 50);

    function outsideClickListener(e) {
        if (!dropdown.contains(e.target) && !triggerBtn.contains(e.target)) {
            closeAllFilterDropdowns();
        }
    }

    dropdown.outsideClickListener = outsideClickListener;
}

function closeAllFilterDropdowns() {
    var dropdown = document.getElementById('activeColFilterDropdown');
    if (dropdown) {
        if (dropdown.outsideClickListener) {
            document.removeEventListener('mousedown', dropdown.outsideClickListener);
        }
        dropdown.remove();
    }
}

function applyTableFilters(tableId) {
    window.tableCurrentPages[tableId] = 1; // Reset to page 1 on new filter
    displayTablePage(tableId);
}

function displayTablePage(tableId) {
    var table = document.getElementById(tableId);
    if (!table) return;

    var pageSize = window.tablePageSize || 8;
    var currentPage = window.tableCurrentPages[tableId] || 1;

    // Get filter parameters
    var searchInput = document.getElementById(tableId.replace('Table', 'Search'));
    var globalQuery = searchInput ? searchInput.value.toLowerCase().trim() : '';

    var rows = table.querySelectorAll('tbody tr');
    var matchingRows = [];

    rows.forEach(function(row) {
        if (row.cells.length === 1 && (row.cells[0].getAttribute('colspan') || 0) > 3) {
            return; // Empty table message row
        }

        var showRow = true;

        // 0. Custom status filter (data-status-hidden attribute)
        if (row.getAttribute('data-status-hidden') === '1') {
            showRow = false;
        }

        // 1. Global Search Check
        if (showRow && globalQuery) {
            var rowText = row.textContent.toLowerCase();
            if (rowText.indexOf(globalQuery) === -1) {
                showRow = false;
            }
        }

        // 2. Column Filters Check
        if (showRow && window.activeTableFilters[tableId]) {
            var colsFilters = window.activeTableFilters[tableId];
            for (var colIdx in colsFilters) {
                if (colsFilters.hasOwnProperty(colIdx)) {
                    var cell = row.cells[parseInt(colIdx, 10)];
                    if (cell) {
                        var cellVal = (cell.getAttribute('data-sort-value') || cell.textContent).trim();
                        var allowedVals = colsFilters[colIdx];
                        if (allowedVals.indexOf(cellVal) === -1) {
                            showRow = false;
                            break;
                        }
                    }
                }
            }
        }

        if (showRow) {
            matchingRows.push(row);
        } else {
            row.style.display = 'none';
        }
    });

    var totalMatching = matchingRows.length;
    var totalPages = Math.ceil(totalMatching / pageSize);

    // If sync requested (e.g. on load or row update), check where selected row is in matchingRows
    if (window.tablePageNeedsSync[tableId]) {
        var selectedIdx = -1;
        for (var i = 0; i < matchingRows.length; i++) {
            if (matchingRows[i].classList.contains('selected')) {
                selectedIdx = i;
                break;
            }
        }
        if (selectedIdx !== -1) {
            currentPage = Math.floor(selectedIdx / pageSize) + 1;
            window.tableCurrentPages[tableId] = currentPage;
        }
        delete window.tablePageNeedsSync[tableId];
    }

    // Bound current page
    if (currentPage > totalPages) {
        currentPage = Math.max(1, totalPages);
        window.tableCurrentPages[tableId] = currentPage;
    }

    var startIndex = (currentPage - 1) * pageSize;
    var endIndex = currentPage * pageSize;

    // Show only rows belonging to the current page
    matchingRows.forEach(function(row, idx) {
        if (idx >= startIndex && idx < endIndex) {
            row.style.display = '';
            row.classList.remove('row-even', 'row-odd');
            row.classList.add(idx % 2 === 0 ? 'row-even' : 'row-odd');
        } else {
            row.style.display = 'none';
        }
    });

    // Update records counter indicator text
    var countEl = document.getElementById(tableId + 'FilterCount');
    if (countEl) {
        if (totalMatching === 0) {
            countEl.textContent = 'Không tìm thấy bản ghi nào';
        } else {
            var currentStart = startIndex + 1;
            var currentEnd = Math.min(endIndex, totalMatching);
            countEl.textContent = 'Hiển thị ' + currentStart + '-' + currentEnd + ' trên ' + totalMatching + ' bản ghi';
        }
        countEl.style.display = '';
    }

    // Render pagination container
    var container = table.closest('.win-table-container');
    if (container) {
        var paginationId = tableId + 'Pagination';
        var paginationEl = document.getElementById(paginationId);
        if (!paginationEl) {
            paginationEl = document.createElement('div');
            paginationEl.className = 'win-table-pagination';
            paginationEl.id = paginationId;
            container.parentNode.insertBefore(paginationEl, container.nextSibling);
        }
        renderTablePagination(tableId, totalMatching, currentPage, totalPages);
    }
}

function renderTablePagination(tableId, totalMatching, currentPage, totalPages) {
    var paginationEl = document.getElementById(tableId + 'Pagination');
    if (!paginationEl) return;

    if (totalPages <= 1) {
        paginationEl.innerHTML = '';
        return;
    }

    var html = '';
    // Previous Page Button
    var prevDisabled = currentPage === 1 ? ' disabled' : '';
    html += '<button type="button" class="page-btn' + prevDisabled + '" data-page="' + (currentPage - 1) + '"><i class="fas fa-chevron-left"></i></button>';

    // Page Numbers Buttons
    for (var i = 1; i <= totalPages; i++) {
        var activeClass = i === currentPage ? ' active' : '';
        html += '<button type="button" class="page-btn' + activeClass + '" data-page="' + i + '">' + i + '</button>';
    }

    // Next Page Button
    var nextDisabled = currentPage === totalPages ? ' disabled' : '';
    html += '<button type="button" class="page-btn' + nextDisabled + '" data-page="' + (currentPage + 1) + '"><i class="fas fa-chevron-right"></i></button>';

    paginationEl.innerHTML = html;

    // Attach click events
    paginationEl.querySelectorAll('.page-btn').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            if (this.classList.contains('disabled') || this.classList.contains('active')) return;
            var targetPage = parseInt(this.getAttribute('data-page'), 10);
            window.tableCurrentPages[tableId] = targetPage;
            displayTablePage(tableId);
        });
    });
}



// ===== CRUD BUTTON HANDLERS =====
function btnThem(formPrefix) {
    // Clear form for new entry
    var form = document.getElementById(formPrefix + 'Form');
    if (form) {
        var inputs = form.querySelectorAll('input[type="text"], input[type="number"], select');
        inputs.forEach(function(inp) { inp.value = ''; inp.readOnly = false; });
    }
    var actionField = document.getElementById(formPrefix + 'Action');
    if (actionField) actionField.value = 'add';
    var pkField = document.getElementById(formPrefix + 'PK');
    if (pkField) { pkField.readOnly = false; pkField.focus(); }
    // Deselect table rows
    document.querySelectorAll('.win-table tbody tr').forEach(function(r) {
        r.classList.remove('selected');
    });
}

function btnXoa(formPrefix, deleteUrl) {
    var pkField = document.getElementById(formPrefix + 'PK');
    if (!pkField || !pkField.value.trim()) {
        alert('Vui lòng chọn dòng cần xóa!');
        return;
    }
    if (confirm('Bạn có chắc chắn muốn xóa?')) {
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = deleteUrl;
        var input = document.createElement('input');
        input.type = 'hidden';
        input.name = pkField.name;
        input.value = pkField.value;
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }
}

function btnPhucHoi() {
    // Reload the page to restore original data
    window.location.reload();
}

function syncTableToSelectedRow(tableId) {
    window.tablePageNeedsSync[tableId] = true;
    displayTablePage(tableId);
}

function btnThoat(homeUrl) {
    window.location.href = homeUrl;
}

// ===== AUTO-CALCULATE GRADE =====
function tinhDiemHetMon(row) {
    var cc = parseFloat(row.querySelector('.diem-cc').value) || 0;
    var gk = parseFloat(row.querySelector('.diem-gk').value) || 0;
    var ck = parseFloat(row.querySelector('.diem-ck').value) || 0;
    var diemHM = cc * 0.1 + gk * 0.3 + ck * 0.6;
    row.querySelector('.diem-hm').textContent = diemHM.toFixed(1);
}

function initGradeCalculation() {
    document.querySelectorAll('.grade-row').forEach(function(row) {
        row.querySelectorAll('.grade-input').forEach(function(input) {
            input.addEventListener('input', function() {
                tinhDiemHetMon(row);
            });
            input.addEventListener('change', function() {
                // Validate range 0-10
                var val = parseFloat(this.value);
                if (isNaN(val) || val < 0) this.value = 0;
                if (val > 10) this.value = 10;
                // Round GK, CK to 0.5
                if (this.classList.contains('diem-gk') || this.classList.contains('diem-ck')) {
                    this.value = (Math.round(val * 2) / 2).toFixed(1);
                }
                tinhDiemHetMon(row);
            });
        });
    });
}

// ===== CONFIRM SUBMIT =====
function confirmSubmit(msg) {
    return confirm(msg || 'Bạn có chắc chắn?');
}

// ===== DOCUMENT READY =====
document.addEventListener('DOMContentLoaded', function() {
    // Highlight active sidebar link
    var currentPath = window.location.pathname;
    document.querySelectorAll('.sidebar .nav-link').forEach(function(link) {
        if (currentPath.indexOf(link.getAttribute('href')) !== -1 && link.getAttribute('href') !== '/') {
            link.classList.add('active');
        }
    });

    // Init grade calculation if on diem page
    if (document.querySelector('.grade-row')) {
        initGradeCalculation();
    }

    // Auto-init column sort and filters on all .win-table tables
    document.querySelectorAll('.win-table').forEach(function(t) {
        if (t.id) {
            initColumnSort(t.id);
            initColumnFilters(t.id);
        }
    });

    // Run a post-init sync after all inline DOMContentLoaded listeners have selected their rows
    setTimeout(function() {
        document.querySelectorAll('.win-table').forEach(function(t) {
            if (t.id) {
                syncTableToSelectedRow(t.id);
            }
        });
    }, 0);

    // Close filter dropdowns when scrolling OUTSIDE the dropdown
    window.addEventListener('scroll', function(e) {
        var dropdown = document.getElementById('activeColFilterDropdown');
        if (dropdown && !dropdown.contains(e.target)) {
            closeAllFilterDropdowns();
        }
    }, true);

    // Auto-dismiss alerts after 5s
    document.querySelectorAll('.alert-dismissible').forEach(function(alert) {
        setTimeout(function() {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(function() { alert.remove(); }, 500);
        }, 5000);
    });
});

// ===== PRINT REPORT =====
function printReport() {
    window.print();
}
