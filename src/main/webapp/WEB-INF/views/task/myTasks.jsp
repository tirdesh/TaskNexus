<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-12">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">My Tasks</h3>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
              <table id="tasksTable" class="table table-bordered table-striped">
                <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Description</th>
                  <th>Project</th>
                  <th>Priority</th>
                  <th>Status</th>
                  <th>Deadline</th>
                  <th>Actions</th>
                </tr>
                </thead>
                <tbody id="tasksBody">
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
$(document).ready(function() {
    loadMyTasks();
});

function loadMyTasks() {
    $.ajax({
        url: '${pageContext.request.contextPath}/myTasks',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var tbody = $('#tasksBody');
                tbody.empty();
                
                if (response.data.length === 0) {
                    tbody.append('<tr><td colspan="8" class="text-center">No tasks assigned to you</td></tr>');
                } else {
                    $.each(response.data, function(index, task) {
                        var row = '<tr>';
                        row += '<td>' + (task.taskId || '') + '</td>';
                        row += '<td>' + (task.name || '') + '</td>';
                        row += '<td>' + (task.description || '') + '</td>';
                        row += '<td>' + (task.project ? task.project.name : '') + '</td>';
                        row += '<td><span class="badge badge-' + getPriorityBadgeClass(task.priority) + '">' + (task.priority || 'N/A') + '</span></td>';
                        row += '<td><select class="form-control form-control-sm task-status" data-task-id="' + task.taskId + '">';
                        row += '<option value="TODO"' + (task.taskStatus === 'TODO' ? ' selected' : '') + '>To Do</option>';
                        row += '<option value="IN_PROGRESS"' + (task.taskStatus === 'IN_PROGRESS' ? ' selected' : '') + '>In Progress</option>';
                        row += '<option value="COMPLETED"' + (task.taskStatus === 'COMPLETED' ? ' selected' : '') + '>Completed</option>';
                        row += '<option value="BLOCKED"' + (task.taskStatus === 'BLOCKED' ? ' selected' : '') + '>Blocked</option>';
                        row += '</select></td>';
                        row += '<td>' + (task.deadline || 'N/A') + '</td>';
                        row += '<td><a href="${pageContext.request.contextPath}/task/' + task.taskId + '" class="btn btn-sm btn-info">View</a></td>';
                        row += '</tr>';
                        tbody.append(row);
                    });
                    
                    // Bind status change event
                    $('.task-status').on('change', function() {
                        var taskId = $(this).data('task-id');
                        var newStatus = $(this).val();
                        updateTaskStatus(taskId, newStatus);
                    });
                }
            } else {
                $('#tasksBody').html('<tr><td colspan="8" class="text-center">' + (response.message || 'Error loading tasks') + '</td></tr>');
            }
        },
        error: function(xhr) {
            $('#tasksBody').html('<tr><td colspan="8" class="text-center text-danger">Error loading tasks</td></tr>');
        }
    });
}

function getPriorityBadgeClass(priority) {
    if (priority === 'HIGH') return 'danger';
    if (priority === 'MEDIUM') return 'warning';
    if (priority === 'LOW') return 'info';
    return 'secondary';
}

function updateTaskStatus(taskId, status) {
    $.ajax({
        url: '${pageContext.request.contextPath}/updateTaskStatus',
        type: 'POST',
        data: { taskId: taskId, status: status },
        success: function(response) {
            if (response.status === '200') {
                alert('Task status updated successfully');
            } else {
                alert(response.message || 'Error updating status');
                loadMyTasks(); // Reload to revert
            }
        },
        error: function() {
            alert('Error updating task status');
            loadMyTasks(); // Reload to revert
        }
    });
}
</script>
</body>
</html>

