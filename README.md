# TaskNexus

A comprehensive project and task management application built with Spring Boot, featuring team collaboration, task tracking, and project organization capabilities.

## Description

TaskNexus is a full-stack web application designed to help teams manage projects and tasks efficiently. It provides a user-friendly interface for creating projects, assigning tasks, tracking progress, and collaborating through comments and file attachments.

## Features

### Project Management
- Create and manage multiple projects
- Assign project managers and team members
- Track project status (Planning, In Progress, Completed, On Hold)
- View project details and associated tasks

### Task Management
- Create tasks with priorities (High, Medium, Low)
- Assign tasks to team members
- Set deadlines and track task status (TODO, In Progress, Completed, Blocked)
- View personal task dashboard
- Task expiration tracking

### User Management
- User registration and authentication
- Role-based access control
- Admin panel for user management
- User profile management

### Collaboration Features
- Add comments to tasks
- Upload file attachments to tasks
- Real-time task and project updates

### Dashboard
- Overview of projects and tasks
- Personal task view
- Project and task statistics

## Tech Stack

### Backend
- **Java 17** - Programming language
- **Spring Boot 3.2.0** - Application framework
- **Hibernate 6.4.0** - ORM framework
- **DAO Pattern** - Data access layer (no Spring Data JPA)
- **Spring Security Crypto** - Password hashing (BCrypt)
- **MySQL** - Database

### Frontend
- **JSP (JavaServer Pages)** - Server-side rendering
- **JSTL** - JSP Standard Tag Library
- **AdminLTE** - Admin dashboard template
- **Bootstrap 4** - CSS framework
- **jQuery** - JavaScript library
- **Font Awesome** - Icons

### Build Tools
- **Maven** - Dependency management and build tool
- **Tomcat Embedded** - Application server

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- MySQL 5.7+ or MySQL 8.0+
- Git (optional)

## Installation & Setup

For detailed setup and installation instructions, see [SETUP.md](SETUP.md).

**Quick Start:**
   ```bash
# Clone repository
   git clone https://github.com/tirdesh/TaskNexus.git
   cd TaskNexus

# Update database credentials in src/main/resources/application.properties

# Build and run
   ./mvnw clean install
   ./mvnw spring-boot:run
   
# Access at http://localhost:8080
# Login: admin@tasknexus.com / password
   ```

## Project Structure

```
TaskNexus/
├── src/
│   ├── main/
│   │   ├── java/com/jsprest/
│   │   │   ├── config/              # Configuration classes
│   │   │   ├── controller/          # REST/Web controllers
│   │   │   ├── dao/                 # Data Access Objects (Hibernate)
│   │   │   ├── entity/              # JPA entities
│   │   │   │   └── enums/           # Enum types
│   │   │   ├── exception/           # Exception handlers
│   │   │   ├── factory/             # Factory classes
│   │   │   ├── serializer/          # Custom serializers
│   │   │   ├── service/             # Business logic layer
│   │   │   ├── TaskNexusApplication.java  # Main application class
│   │   │   └── ServletInitializer.java    # WAR deployment initializer
│   │   ├── resources/
│   │   │   ├── application.properties     # Application configuration
│   │   │   ├── data.sql                   # Initial data script
│   │   │   └── static/                    # Static resources (CSS, JS, images)
│   │   └── webapp/
│   │       └── WEB-INF/views/             # JSP view files
│   └── test/
│       └── java/com/jsprest/
│           └── TaskNexusApplicationTests.java  # Application tests
├── pom.xml                          # Maven configuration
├── mvnw / mvnw.cmd                  # Maven wrapper scripts
├── LICENSE                           # License file
├── README.md                         # This file
├── REQUIREMENTS_COMPLIANCE_REPORT.md # Compliance documentation
└── CHANGES_SUMMARY.md                # Changes documentation
```

## Database Schema

The application uses the following main entities:
- **Users** - User accounts and profiles
- **Admin** - Administrator accounts
- **Role** - User roles
- **Project** - Project information
- **Task** - Task details with assignments
- **Comment** - Task comments
- **Attachment** - File attachments for tasks

## Configuration

Key configuration options in `application.properties`:

- **Database**: MySQL connection settings
- **Server Port**: Default 8080
- **File Upload**: Max file size 10MB
- **JPA/Hibernate**: Auto DDL update enabled

## API Endpoints

The application provides RESTful endpoints for:
- User management (`/user/*`)
- Project management (`/project/*`)
- Task management (`/task/*`)
- Comment management (`/comment/*`)
- Attachment management (`/attachment/*`)
- Admin operations (`/admin/*`)

## Development

### Running in Development Mode

The application includes Spring Boot DevTools for hot reloading during development.

### Building for Production

```bash
./mvnw clean package
```

This creates a WAR file (`TaskNexus-0.0.1-SNAPSHOT.war`) in the `target/` directory that can be deployed to a servlet container like Tomcat, Jetty, or WebLogic.

## Requirements Compliance

This project follows specific architectural requirements:
- ✅ JSP-based frontend (no React)
- ✅ JPA annotations for entity mapping
- ✅ Hibernate with custom DAO pattern (no Spring Data JPA)
- ✅ Annotation-based mapping (no XML)
- ✅ No wildcard imports

See `REQUIREMENTS_COMPLIANCE_REPORT.md` for detailed compliance information.

## License

See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Developed as a comprehensive project management solution.

---

For more information, visit the [GitHub repository](https://github.com/tirdesh/TaskNexus).
