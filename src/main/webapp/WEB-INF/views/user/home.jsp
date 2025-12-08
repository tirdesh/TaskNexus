<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Users</h1>
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
                <h3 class="card-title">All Users</h3>
                <button class="btn btn-primary float-sm-right" onclick="window.location.href='${pageContext.request.contextPath}/addUser';">Add User</button>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
<table id="example1" class="table table-bordered table-striped">
                  <thead>
                  <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Registered</th>
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

submit = function(){
$.ajax({
url:'saveOrUpdate',
type:'POST',
data:{user_id:$("#user_id").val(),user_name:$('#name').val(),email:$('#email').val()},
success: function(response){
alert(response.message);
load();
}
});
}

deleteUser_ = function(id){
if (!confirm('Are you sure you want to delete this user?')) {
return;
}
$.ajax({
url:'deleteUser',
type:'POST',
data:{user_id:id},
success: function(response){
alert(response.message);
load();
},
error: function() {
alert('Error deleting user');
}
});
}

edit = function (index){
if (!data || !data[index]) {
alert('User data not available');
return;
}
var user = data[index];
window.location.href = '${pageContext.request.contextPath}/addUser?userId=' + user.user_id;
}

load = function(){
$.ajax({
url:'list',
type:'POST',
success: function(response){
data = response.data;
$('#example1 tbody').empty();
if(response.data && response.data.length > 0) {
for(i=0; i<response.data.length; i++){
var user = response.data[i];
var isRegistered = user.password && user.password.length > 0 ? '<span class="badge badge-success">Yes</span>' : '<span class="badge badge-warning">No</span>';
var row = '<tr class="tr">';
row += '<td>' + (user.user_id || '') + '</td>';
row += '<td>' + (user.user_name || '') + '</td>';
row += '<td>' + (user.email || '') + '</td>';
row += '<td>' + isRegistered + '</td>';
row += '<td>';
row += '<a href="#" onclick="edit(' + i + '); return false;" class="btn btn-sm btn-warning">Edit</a> ';
row += '<a href="#" onclick="deleteUser_(' + user.user_id + '); return false;" class="btn btn-sm btn-danger">Delete</a>';
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
