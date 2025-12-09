<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Tasks</h1>
          </div>
        </div>
      </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-12">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">All Tasks</h3>
                <button class="btn btn-primary float-sm-right" onclick="window.location.href='${pageContext.request.contextPath}/addTask';">Add Task</button>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
<table id="example1" class="table table-bordered table-striped">
                  <thead>
                  <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Project</th>
                    <th>Priority</th>
                    <th>Status</th>
                    <th>Assigned To</th>
                    <th>Deadline</th>
                    <th>Actions</th>
                  </tr>
                  </thead>
                  <tbody>
                  </tbody>
              </table>
              </div>
              <!-- /.card-body -->
            </div>
            <!-- /.card -->
          </div>
          <!-- /.col -->
        </div>
        <!-- /.row -->
      </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->
  <jsp:include page="/WEB-INF/views/layout/footer.jsp"></jsp:include>

<script type="text/javascript">
data = "";

deleteTask_ = function(id){
if (!confirm('Are you sure you want to delete this task?')) {
return;
}
$.ajax({
url:'deleteTask',
type:'POST',
data:{taskId:id},
success: function(response){
alert(response.message);
load();
},
error: function() {
alert('Error deleting task');
}
});
}

edit = function (index){
var task = data[index];
if (task && task.taskId) {
window.location.href = '${pageContext.request.contextPath}/addTask?taskId=' + task.taskId;
}
}

load = function(){
$.ajax({
url:'allTask',
type:'POST',
success: function(response){
data = response.data;
$('#example1 tbody').empty();
if(response.data && response.data.length > 0) {
for(i=0; i<response.data.length; i++){
var task = response.data[i];
var row = '<tr class="tr">';
row += '<td>' + (task.taskId || '') + '</td>';
row += '<td>' + (task.name || '') + '</td>';
row += '<td>' + (task.description || '') + '</td>';
row += '<td>' + (task.project ? task.project.name : 'N/A') + '</td>';
row += '<td><span class="badge badge-' + getPriorityBadge(task.priority) + '">' + (task.priority || 'N/A') + '</span></td>';
row += '<td><span class="badge badge-primary">' + (task.taskStatus || 'N/A') + '</span></td>';
row += '<td>' + (task.assignedTo ? task.assignedTo.user_name : 'Unassigned') + '</td>';
row += '<td>' + (task.deadline || 'N/A') + '</td>';
row += '<td>';
row += '<a href="${pageContext.request.contextPath}/task/' + task.taskId + '" class="btn btn-sm btn-info">View</a> ';
row += '<a href="#" onclick="edit(' + i + '); return false;" class="btn btn-sm btn-warning">Edit</a> ';
row += '<a href="#" onclick="deleteTask_(' + task.taskId + '); return false;" class="btn btn-sm btn-danger">Delete</a>';
row += '</td>';
row += '</tr>';
$("#example1 tbody").append(row);
}
}
}
});
}

function getPriorityBadge(priority) {
if (priority === 'HIGH') return 'danger';
if (priority === 'MEDIUM') return 'warning';
if (priority === 'LOW') return 'info';
return 'secondary';
}

$(document).ready(function() {
load();
});
</script>
