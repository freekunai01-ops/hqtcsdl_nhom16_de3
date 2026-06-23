#!/bin/bash
# Chờ SQL Server khởi động hoàn tất
echo "Waiting for SQL Server to start..."
for i in {1..50}; do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -Q "SELECT 1" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server is ready! Starting database initialization..."
        
        # 1. Tạo cấu trúc cơ sở dữ liệu
        echo "Running create_db_schema.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/create_db_schema.sql
        
        # 2. Tạo stored procedures & views
        echo "Running sp_and_views.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/sp_and_views.sql
        
        # 3. Tạo các Stored Procedures CRUD mới
        echo "Running sp_crud.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/sp_crud.sql
        
        # 4. Tạo login, phân quyền bảo mật (khoa_all, pgv_admin, sv)
        echo "Running setup_security.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/setup_security.sql
        
        # 5. Sinh dữ liệu mẫu đầy đủ
        echo "Running mock_data_full.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/mock_data_full.sql
        
        echo "Database initialization completed successfully!"
        break
    else
        echo "SQL Server is starting up, waiting..."
        sleep 2
    fi
done
