# PowerShell script to create SerenaSouvenirSanctuary database
Write-Host "Setting up SerenaSouvenirSanctuary Database..." -ForegroundColor Green

try {
    # Add System.Data assembly
    Add-Type -AssemblyName System.Data

    # Connection string for master database
    $masterConnectionString = "Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;Connect Timeout=30"
    
    Write-Host "Connecting to LocalDB..." -ForegroundColor Yellow
    
    # Create connection to master database
    $connection = New-Object System.Data.SqlClient.SqlConnection($masterConnectionString)
    $connection.Open()
    
    Write-Host "Connected successfully!" -ForegroundColor Green
    
    # Check if database exists
    $checkDbCommand = $connection.CreateCommand()
    $checkDbCommand.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name = 'SerenaSouvenirSanctuary'"
    $dbExists = $checkDbCommand.ExecuteScalar()
    
    if ($dbExists -eq 0) {
        Write-Host "Creating database 'SerenaSouvenirSanctuary'..." -ForegroundColor Yellow
        
        # Create database
        $createDbCommand = $connection.CreateCommand()
        $createDbCommand.CommandText = "CREATE DATABASE SerenaSouvenirSanctuary"
        $createDbCommand.ExecuteNonQuery()
        
        Write-Host "Database created successfully!" -ForegroundColor Green
    } else {
        Write-Host "Database 'SerenaSouvenirSanctuary' already exists." -ForegroundColor Yellow
    }
    
    $connection.Close()
    
    # Now connect to the new database and create tables
    $dbConnectionString = "Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=SerenaSouvenirSanctuary;Integrated Security=True;Connect Timeout=30"
    $dbConnection = New-Object System.Data.SqlClient.SqlConnection($dbConnectionString)
    $dbConnection.Open()
    
    Write-Host "Creating tables..." -ForegroundColor Yellow
    
    # Create Users table
    $createUsersCommand = $dbConnection.CreateCommand()
    $createUsersCommand.CommandText = @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
CREATE TABLE [Users] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [FullName] nvarchar(100) NOT NULL,
    [Email] nvarchar(100) NOT NULL UNIQUE,
    [Password] nvarchar(255) NOT NULL,
    [Role] nvarchar(20) NOT NULL DEFAULT 'Customer',
    [IsActive] bit NOT NULL DEFAULT 1,
    [CreatedDate] datetime NOT NULL DEFAULT GETDATE()
);
"@
    $createUsersCommand.ExecuteNonQuery()
    Write-Host "Users table created." -ForegroundColor Green
    
    # Create Products table
    $createProductsCommand = $dbConnection.CreateCommand()
    $createProductsCommand.CommandText = @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
CREATE TABLE [Products] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [Name] nvarchar(100) NOT NULL,
    [Description] nvarchar(1000) NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [ImageUrl] nvarchar(500) NULL,
    [Category] nvarchar(50) NOT NULL,
    [StockQuantity] int NOT NULL DEFAULT 0,
    [Brand] nvarchar(50) NULL,
    [SKU] nvarchar(20) NULL,
    [IsActive] bit NOT NULL DEFAULT 1,
    [CreatedDate] datetime NOT NULL DEFAULT GETDATE()
);
"@
    $createProductsCommand.ExecuteNonQuery()
    Write-Host "Products table created." -ForegroundColor Green
    
    # Create other tables
    $createOtherTablesCommand = $dbConnection.CreateCommand()
    $createOtherTablesCommand.CommandText = @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CartItems' AND xtype='U')
CREATE TABLE [CartItems] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [SessionId] nvarchar(255) NOT NULL,
    [ProductId] int NOT NULL,
    [Quantity] int NOT NULL,
    [DateAdded] datetime NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY ([ProductId]) REFERENCES [Products]([Id])
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')
CREATE TABLE [Orders] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [OrderNumber] nvarchar(20) NOT NULL UNIQUE,
    [UserId] int NULL,
    [CustomerName] nvarchar(100) NOT NULL,
    [CustomerEmail] nvarchar(100) NOT NULL,
    [CustomerPhone] nvarchar(20) NULL,
    [ShippingAddress] nvarchar(500) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PaymentMethod] nvarchar(20) NOT NULL,
    [OrderStatus] nvarchar(20) NOT NULL DEFAULT 'Pending',
    [OrderDate] datetime NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY ([UserId]) REFERENCES [Users]([Id])
);
"@
    $createOtherTablesCommand.ExecuteNonQuery()
    Write-Host "Other tables created." -ForegroundColor Green
    
    # Insert default data
    Write-Host "Inserting default data..." -ForegroundColor Yellow
    
    # Insert admin user
    $insertAdminCommand = $dbConnection.CreateCommand()
    $insertAdminCommand.CommandText = @"
IF NOT EXISTS (SELECT * FROM Users WHERE Email = 'admin@serena.com')
INSERT INTO [Users] ([FullName], [Email], [Password], [Role]) 
VALUES ('System Administrator', 'admin@serena.com', 'Admin123!', 'Admin');
"@
    $insertAdminCommand.ExecuteNonQuery()
    Write-Host "Admin user created." -ForegroundColor Green
    
    # Insert sample products
    $insertProductsCommand = $dbConnection.CreateCommand()
    $insertProductsCommand.CommandText = @"
IF NOT EXISTS (SELECT * FROM Products WHERE Name = 'Sample Product 1')
INSERT INTO [Products] ([Name], [Description], [Price], [Category], [StockQuantity])
VALUES 
('Sample Product 1', 'This is a sample product for testing', 29.99, 'Souvenirs', 100),
('Sample Product 2', 'Another sample product', 19.99, 'Gifts', 50),
('Sample Product 3', 'Third sample product', 39.99, 'Collectibles', 25);
"@
    $insertProductsCommand.ExecuteNonQuery()
    Write-Host "Sample products created." -ForegroundColor Green
    
    $dbConnection.Close()
    
    Write-Host "" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Database setup completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "Default Admin Account:" -ForegroundColor Cyan
    Write-Host "Username: admin@serena.com" -ForegroundColor White
    Write-Host "Password: Admin123!" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "You can now run your application!" -ForegroundColor Green
    
} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.Exception.StackTrace)" -ForegroundColor Red
}

Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 