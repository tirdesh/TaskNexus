<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">
              <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
            </h1>
          </div>
        </div>
      </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        <!-- Statistics Cards -->
        <div class="row" id="dashboardCards">
          <!-- Projects Card -->
          <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
            <div class="info-box shadow-lg">
              <span class="info-box-icon bg-info elevation-2">
                <i class="fas fa-project-diagram"></i>
              </span>
              <div class="info-box-content">
                <span class="info-box-text">Total Projects</span>
                <span class="info-box-number">
                  <span id="projectCount" class="count-number">0</span>
                </span>
                <div class="progress">
                  <div class="progress-bar bg-info" style="width: 100%"></div>
              </div>
                <span class="progress-description">
                  <a href="${pageContext.request.contextPath}/viewProject" class="text-info">
                    View all projects <i class="fas fa-arrow-right ml-1"></i>
                  </a>
                </span>
              </div>
            </div>
          </div>

          <!-- Tasks Card -->
          <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
            <div class="info-box shadow-lg">
              <span class="info-box-icon bg-success elevation-2">
                <i class="fas fa-tasks"></i>
              </span>
              <div class="info-box-content">
                <span class="info-box-text">Total Tasks</span>
                <span class="info-box-number">
                  <span id="taskCount" class="count-number">0</span>
                </span>
                <div class="progress">
                  <div class="progress-bar bg-success" style="width: 100%"></div>
                </div>
                <span class="progress-description">
                  <a href="${pageContext.request.contextPath}/viewTask" class="text-success">
                    View all tasks <i class="fas fa-arrow-right ml-1"></i>
                  </a>
                </span>
              </div>
            </div>
          </div>

          <!-- Users Card (Admin Only) -->
          <sec:authorize access="hasAuthority('ROLE_ADMIN')">
          <div class="col-lg-3 col-md-6 col-sm-6 mb-4" id="userCard">
            <div class="info-box shadow-lg">
              <span class="info-box-icon bg-warning elevation-2">
                <i class="fas fa-users"></i>
              </span>
              <div class="info-box-content">
                <span class="info-box-text">Total Users</span>
                <span class="info-box-number">
                  <span id="userCount" class="count-number">0</span>
                </span>
                <div class="progress">
                  <div class="progress-bar bg-warning" style="width: 100%"></div>
                </div>
                <span class="progress-description">
                  <a href="${pageContext.request.contextPath}/viewUser" class="text-warning">
                    Manage users <i class="fas fa-arrow-right ml-1"></i>
                  </a>
                </span>
              </div>
            </div>
          </div>
          </sec:authorize>

          <!-- Active Tasks Card -->
          <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
            <div class="info-box shadow-lg">
              <span class="info-box-icon bg-danger elevation-2">
                <i class="fas fa-check-circle"></i>
              </span>
              <div class="info-box-content">
                <span class="info-box-text">Active Tasks</span>
                <span class="info-box-number">
                  <span id="activeTaskCount" class="count-number">0</span>
                </span>
                <div class="progress">
                  <div class="progress-bar bg-danger" style="width: 100%"></div>
                </div>
                <span class="progress-description">
                  <a href="${pageContext.request.contextPath}/viewTask?active=true" class="text-danger">
                    View active tasks <i class="fas fa-arrow-right ml-1"></i>
                  </a>
                </span>
              </div>
            </div>
          </div>

          <!-- My Tasks Card (Non-Admin) -->
          <sec:authorize access="!hasAuthority('ROLE_ADMIN')">
          <div class="col-lg-3 col-md-6 col-sm-6 mb-4" id="myTasksCard">
            <div class="info-box shadow-lg">
              <span class="info-box-icon bg-primary elevation-2">
                <i class="fas fa-user-check"></i>
              </span>
              <div class="info-box-content">
                <span class="info-box-text">My Tasks</span>
                <span class="info-box-number">
                  <span id="myTaskCount" class="count-number">0</span>
                </span>
                <div class="progress">
                  <div class="progress-bar bg-primary" style="width: 100%"></div>
                </div>
                <span class="progress-description">
                  <a href="${pageContext.request.contextPath}/myTasks" class="text-primary">
                    View my tasks <i class="fas fa-arrow-right ml-1"></i>
                  </a>
                </span>
              </div>
            </div>
          </div>
          </sec:authorize>
        </div>
        <!-- /.row -->

        <!-- Quick Actions Section (Admin Only) -->
        <sec:authorize access="hasAuthority('ROLE_ADMIN')">
        <div class="row">
          <div class="col-12">
            <div class="card card-primary card-outline">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fas fa-bolt mr-2"></i>Quick Actions
                </h3>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-4 col-sm-6 mb-3">
                    <a href="${pageContext.request.contextPath}/addProject" class="btn btn-block btn-info btn-lg">
                      <i class="fas fa-plus-circle mr-2"></i>Add Project
                    </a>
                  </div>
                  <div class="col-md-4 col-sm-6 mb-3">
                    <a href="${pageContext.request.contextPath}/addTask?returnTo=viewTask" class="btn btn-block btn-success btn-lg">
                      <i class="fas fa-plus-circle mr-2"></i>Add Task
                    </a>
                  </div>
                  <div class="col-md-4 col-sm-6 mb-3">
                    <a href="${pageContext.request.contextPath}/addUser" class="btn btn-block btn-warning btn-lg">
                      <i class="fas fa-user-plus mr-2"></i>Add User
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- /.row -->
        </sec:authorize>
      </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->
  <jsp:include page="/WEB-INF/views/layout/footer.jsp"></jsp:include>

<script type="text/javascript">
$(document).ready(function() {
    loadDashboardStats();
});

function loadDashboardStats() {
    $.ajax({
        url: '${pageContext.request.contextPath}/dashboard/stats',
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response) {
                // Animate numbers
                animateValue('projectCount', 0, response.totalProjects || 0, 1000);
                animateValue('taskCount', 0, response.totalTasks || 0, 1000);
                animateValue('userCount', 0, response.totalUsers || 0, 1000);
                animateValue('activeTaskCount', 0, response.activeTasks || 0, 1000);
                animateValue('myTaskCount', 0, response.myTasks || 0, 1000);
            }
        },
        error: function() {
            $('#projectCount').text('Error');
            $('#taskCount').text('Error');
            $('#userCount').text('Error');
            $('#activeTaskCount').text('Error');
            $('#myTaskCount').text('Error');
        }
    });
}

// Animate number counting
function animateValue(id, start, end, duration) {
    var obj = document.getElementById(id);
    if (!obj) return;
    
    var range = end - start;
    var minTimer = 50;
    var stepTime = Math.abs(Math.floor(duration / range));
    stepTime = Math.max(stepTime, minTimer);
    
    var startTime = new Date().getTime();
    var endTime = startTime + duration;
    var timer;
    
    function run() {
        var now = new Date().getTime();
        var remaining = Math.max((endTime - now) / duration, 0);
        var value = Math.round(end - (remaining * range));
        obj.textContent = value;
        if (value == end) {
            clearInterval(timer);
        }
    }
    
    timer = setInterval(run, stepTime);
    run();
}
</script>
