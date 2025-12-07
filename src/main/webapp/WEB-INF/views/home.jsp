<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Dashboard</h1>
          </div>
        </div>
      </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        <!-- Small boxes (Stat box) -->
        <div class="row">
          <div class="col-lg-3 col-6">
            <!-- small box -->
            <div class="small-box bg-info">
              <div class="inner">
                <h3 id="projectCount">0</h3>
                <p>Projects</p>
              </div>
              <div class="icon">
                <i class="fas fa-folder"></i>
              </div>
              <a href="${pageContext.request.contextPath}/viewProject" class="small-box-footer">
                More info <i class="fas fa-arrow-circle-right"></i>
              </a>
            </div>
          </div>
          <!-- ./col -->
          <div class="col-lg-3 col-6">
            <!-- small box -->
            <div class="small-box bg-success">
              <div class="inner">
                <h3 id="taskCount">0</h3>
                <p>Tasks</p>
              </div>
              <div class="icon">
                <i class="fas fa-tasks"></i>
              </div>
              <a href="${pageContext.request.contextPath}/viewTask" class="small-box-footer">
                More info <i class="fas fa-arrow-circle-right"></i>
              </a>
            </div>
          </div>
          <!-- ./col -->
          <div class="col-lg-3 col-6">
            <!-- small box -->
            <div class="small-box bg-warning">
              <div class="inner">
                <h3 id="userCount">0</h3>
                <p>Users</p>
              </div>
              <div class="icon">
                <i class="fas fa-users"></i>
              </div>
              <a href="${pageContext.request.contextPath}/viewUser" class="small-box-footer">
                More info <i class="fas fa-arrow-circle-right"></i>
              </a>
            </div>
          </div>
          <!-- ./col -->
          <div class="col-lg-3 col-6">
            <!-- small box -->
            <div class="small-box bg-danger">
              <div class="inner">
                <h3 id="activeTaskCount">0</h3>
                <p>Active Tasks</p>
              </div>
              <div class="icon">
                <i class="fas fa-check-circle"></i>
              </div>
              <a href="${pageContext.request.contextPath}/viewTask" class="small-box-footer">
                More info <i class="fas fa-arrow-circle-right"></i>
              </a>
            </div>
          </div>
          <!-- ./col -->
        </div>
        <!-- /.row -->
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
    // Load project count
    $.ajax({
        url: '${pageContext.request.contextPath}/allProject',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                $('#projectCount').text(response.data.length);
            }
        },
        error: function() {
            $('#projectCount').text('0');
        }
    });

    // Load task count
    $.ajax({
        url: '${pageContext.request.contextPath}/allTask',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var totalTasks = response.data.length;
                var activeTasks = response.data.filter(function(task) {
                    if (!task.taskStatus) return false;
                    var status = task.taskStatus.toString().toUpperCase();
                    return status === 'IN_PROGRESS' || status === 'TODO' || status === 'BLOCKED';
                }).length;
                $('#taskCount').text(totalTasks);
                $('#activeTaskCount').text(activeTasks);
            }
        },
        error: function() {
            $('#taskCount').text('0');
            $('#activeTaskCount').text('0');
        }
    });

    // Load user count
    $.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                $('#userCount').text(response.data.length);
            }
        },
        error: function() {
            $('#userCount').text('0');
        }
    });
}
</script>

