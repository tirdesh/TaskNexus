# TaskNexus - Setup and Installation Guide

This guide provides detailed instructions for setting up and running TaskNexus on your local machine.

## Prerequisites

Before starting, ensure you have the following installed:

- **Java 17 or higher** - Check with `java -version`
- **Maven 3.6+** - Check with `mvn -version` (or use the included Maven wrapper)
- **MySQL 5.7+ or MySQL 8.0+** - Check with `mysql --version`
- **Git** (optional, for cloning the repository)

## Quick Start

If you have all prerequisites installed:

```bash
# 1. Clone and navigate
git clone https://github.com/tirdesh/TaskNexus.git
cd TaskNexus

# 2. Update database credentials in src/main/resources/application.properties
#    (username and password)

# 3. Build and run
./mvnw clean install
./mvnw spring-boot:run

# 4. Open http://localhost:8080
# 5. Login with: admin@tasknexus.com / password
```

For detailed instructions, continue reading below.

## Step-by-Step Installation

### Step 1: Verify Prerequisites

#### Check Java Version
```bash
java -version
```
You should see Java 17 or higher. If not installed, download from [Oracle](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://openjdk.org/).

#### Check Maven (Optional)
```bash
mvn -version
```
If Maven is not installed, you can use the included Maven wrapper (`./mvnw` or `mvnw.cmd`).

#### Check MySQL
```bash
mysql --version
```
If MySQL is not installed:
- **macOS**: `brew install mysql` or download from [MySQL](https://dev.mysql.com/downloads/mysql/)
- **Linux**: `sudo apt-get install mysql-server` (Ubuntu/Debian) or `sudo yum install mysql-server` (CentOS/RHEL)
- **Windows**: Download from [MySQL](https://dev.mysql.com/downloads/mysql/)

### Step 2: Clone the Repository

```bash
git clone https://github.com/tirdesh/TaskNexus.git
cd TaskNexus
```

Or if you already have the repository:
```bash
cd TaskNexus
```

### Step 3: Configure Database

#### 3.1 Start MySQL Server

**On macOS/Linux:**
```bash
mysql.server start
# or
sudo systemctl start mysql
```

**On Windows (as Administrator):**
```bash
net start MySQL
```

Or start MySQL from Services (services.msc).

#### 3.2 Create Database (Optional)

The database will be created automatically if `createDatabaseIfNotExist=true` is set in the connection URL. However, you can create it manually:

```sql
CREATE DATABASE dbpro;
```

#### 3.3 Update Database Configuration

Edit `src/main/resources/application.properties` and update the database credentials:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/dbpro?useSSL=false&createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=your_password
```

⚠️ **Important**: 
- Replace `your_password` with your actual MySQL root password
- If you're using a different MySQL user, update both `username` and `password`
- Ensure the database name matches (default is `dbpro`)

### Step 4: Build the Project

**On macOS/Linux:**
```bash
./mvnw clean install
```

**On Windows:**
```bash
mvnw.cmd clean install
```

This will:
- Download all Maven dependencies
- Compile the source code
- Run unit tests
- Package the application as a WAR file

**Expected Output:**
```
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

### Step 5: Run the Application

You have three options to run the application:

#### Option A: Using Maven (Recommended for Development)

**On macOS/Linux:**
```bash
./mvnw spring-boot:run
```

**On Windows:**
```bash
mvnw.cmd spring-boot:run
```

This starts the embedded Tomcat server and runs the application.

#### Option B: Using the WAR File

```bash
# Build the WAR file first
./mvnw clean package

# Run the WAR file
java -jar target/TaskNexus-0.0.1-SNAPSHOT.war
```

#### Option C: Deploy to External Servlet Container

1. Build the WAR file:
   ```bash
   ./mvnw clean package
   ```

2. Deploy `target/TaskNexus-0.0.1-SNAPSHOT.war` to:
   - **Tomcat**: Copy to `$CATALINA_HOME/webapps/`
   - **Jetty**: Deploy using Jetty's deployment mechanism
   - **WebLogic**: Use WebLogic's admin console or deployment tools

### Step 6: Access the Application

1. **Open your browser** and navigate to: `http://localhost:8080`
2. **Default port**: 8080 (configurable in `application.properties`)

You should see the TaskNexus login page.

### Step 7: Login

#### Default Admin Credentials:
- **Email**: `admin@tasknexus.com`
- **Password**: `password`

#### Test User Credentials:
- **Project Manager**: `pm1@tasknexus.com` / `password`
- **Team Member 1**: `tm1@tasknexus.com` / `password`
- **Team Member 2**: `tm2@tasknexus.com` / `password`

> ⚠️ **Security Note**: Change default passwords in production! The initial data is loaded from `src/main/resources/data.sql` when `spring.sql.init.mode` is set to `always` (currently set to `never` to preserve data).

## Configuration

### Changing the Server Port

Edit `src/main/resources/application.properties`:
```properties
server.port=8081
```

### Database Initialization

By default, `spring.sql.init.mode=never` to preserve data across restarts.

To reset/seed the database:
1. Set `spring.sql.init.mode=always` in `application.properties`
2. Restart the application
3. **Important**: Change back to `never` after initial setup to preserve data

### File Upload Settings

Default maximum file size is 10MB. To change:
```properties
spring.servlet.multipart.max-file-size=20MB
spring.servlet.multipart.max-request-size=20MB
```

## Troubleshooting

### Port Already in Use

**Error**: `Port 8080 is already in use`

**Solution**: 
1. Change the port in `application.properties`: `server.port=8081`
2. Or stop the process using port 8080:
   ```bash
   # Find process using port 8080
   lsof -i :8080  # macOS/Linux
   netstat -ano | findstr :8080  # Windows
   
   # Kill the process (replace PID with actual process ID)
   kill -9 <PID>  # macOS/Linux
   taskkill /PID <PID> /F  # Windows
   ```

### Database Connection Error

**Error**: `Communications link failure` or `Access denied`

**Solutions**:
1. Verify MySQL is running:
   ```bash
   mysql -u root -p
   ```

2. Check credentials in `application.properties` match your MySQL setup

3. Ensure database `dbpro` exists or `createDatabaseIfNotExist=true` is set:
   ```sql
   CREATE DATABASE IF NOT EXISTS dbpro;
   ```

4. Check MySQL user permissions:
   ```sql
   GRANT ALL PRIVILEGES ON dbpro.* TO 'root'@'localhost';
   FLUSH PRIVILEGES;
   ```

### Build Errors

**Error**: Compilation errors or dependency issues

**Solutions**:
1. Clean and rebuild:
   ```bash
   ./mvnw clean install
   ```

2. Check Java version (must be 17+):
   ```bash
   java -version
   ```

3. Delete `target/` directory and rebuild:
   ```bash
   rm -rf target/  # macOS/Linux
   rmdir /s target  # Windows
   ./mvnw clean install
   ```

4. Clear Maven cache (if dependency issues persist):
   ```bash
   rm -rf ~/.m2/repository  # macOS/Linux
   # Windows: Delete C:\Users\<username>\.m2\repository
   ```

### Application Won't Start

**Error**: Application fails to start or crashes immediately

**Solutions**:
1. Check console logs for specific error messages

2. Verify database connection:
   - MySQL server is running
   - Database credentials are correct
   - Database exists or can be created

3. Check port availability:
   - Port 8080 (or configured port) is not in use
   - Firewall is not blocking the port

4. Verify file permissions:
   - Application has read/write access to `uploads/` directory
   - Application can read configuration files

5. Check Java version compatibility:
   ```bash
   java -version  # Must be Java 17+
   ```

### JSP Pages Not Rendering

**Error**: 404 errors or JSP not found

**Solutions**:
1. Ensure you're using the WAR packaging (not JAR)
2. Check that JSP files are in `src/main/webapp/WEB-INF/views/`
3. Verify `spring.mvc.view.prefix` and `spring.mvc.view.suffix` in `application.properties`

### Static Resources Not Loading

**Error**: CSS, JS, or images not loading

**Solutions**:
1. Clear browser cache
2. Check that static resources are in `src/main/resources/static/`
3. Verify no context path is set (should be root `/`)
4. Check browser console for 404 errors

## Development Mode

The application includes Spring Boot DevTools for hot reloading:

1. Make changes to Java files
2. Save the file
3. DevTools will automatically restart the application

**Note**: JSP changes may require a manual restart or browser refresh.

## Production Deployment

### Building for Production

```bash
./mvnw clean package -DskipTests
```

This creates `target/TaskNexus-0.0.1-SNAPSHOT.war`

### Production Checklist

- [ ] Change default admin password
- [ ] Update database credentials
- [ ] Set `spring.sql.init.mode=never`
- [ ] Configure proper logging
- [ ] Set up SSL/HTTPS
- [ ] Configure proper file upload limits
- [ ] Set up database backups
- [ ] Configure production database connection pool
- [ ] Disable debug mode
- [ ] Set up monitoring and logging

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Maven Documentation](https://maven.apache.org/guides/)

## Getting Help

If you encounter issues not covered in this guide:

1. Check the application logs in the console
2. Review `REQUIREMENTS_COMPLIANCE_REPORT.md` for architecture details
3. Check the [GitHub Issues](https://github.com/tirdesh/TaskNexus/issues)
4. Review the main [README.md](README.md) for project overview

---

**Last Updated**: December 2024

