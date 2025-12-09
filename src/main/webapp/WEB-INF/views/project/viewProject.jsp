<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Projects</h1>
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
                <h3 class="card-title">All Projects</h3>
                <button class="btn btn-primary float-sm-right" onclick="window.location.href='${pageContext.request.contextPath}/addProject';">Add Project</button>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
              <table id="example1" class="table table-bordered table-striped">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Status</th>
                    <th>Project Manager</th>
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

deleteProject_ = function(id){
if (!confirm('Are you sure you want to delete this project?')) {
return;
}
$.ajax({
url:'deleteProject',
type:'POST',
data:{projectId:id},
success: function(response){
alert(response.message);
load();
},
error: function() {
alert('Error deleting project');
}
});
}

view = function(projectId) {
    if (projectId) {
        window.location.href = '${pageContext.request.contextPath}/project/' + projectId;
    }
}

edit = function (index){
var project = data[index];
if (project && project.projectId) {
window.location.href = '${pageContext.request.contextPath}/addProject?projectId=' + project.projectId;
}
}

load = function(){
$.ajax({
url:'allProject',
type:'POST',
success: function(response){
data = response.data;
$('#example1 tbody').empty();
if(response.data && response.data.length > 0) {
for(i=0; i<response.data.length; i++){
var project = response.data[i];
var row = '<tr class="tr">';
row += '<td>' + (project.projectId || '') + '</td>';
row += '<td>' + (project.name || '') + '</td>';
row += '<td>' + (project.description || '') + '</td>';
row += '<td><span class="badge badge-primary">' + (project.projectStatus || 'N/A') + '</span></td>';
row += '<td>' + (project.projectManager ? project.projectManager.user_name : 'Not assigned') + '</td>';
row += '<td>';
row += '<a href="#" onclick="view(' + project.projectId + '); return false;" class="btn btn-sm btn-info">View</a> ';
row += '<a href="#" onclick="edit(' + i + '); return false;" class="btn btn-sm btn-warning">Edit</a> ';
row += '<a href="#" onclick="deleteProject_(' + project.projectId + '); return false;" class="btn btn-sm btn-danger">Delete</a>';
row += '</td>';
row += '</tr>';
$("#example1 tbody").append(row);
}
}
}
});
}

$(document).ready(function() {
load();
});
</script>
