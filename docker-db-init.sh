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
        
        # 2. Tạo login, phân quyền bảo mật (khoa_all, pgv_admin, sv)
        echo "Running setup_security.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/setup_security.sql
        
        # 3. Sinh dữ liệu mẫu đầy đủ
        echo "Running add_full_mock_data.sql..."
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 123456 -i /usr/config/sql/add_full_mock_data.sql
        
        echo "Database initialization completed successfully!"
        break
    else
        echo "SQL Server is starting up, waiting..."
        sleep 2
    fi
done
