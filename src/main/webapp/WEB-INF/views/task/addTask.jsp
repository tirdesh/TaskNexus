<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-md-12">
            <!-- general form elements -->
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Add Task</h3>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
                <input type="hidden" id="taskId">
                
                <div class="form-group">
                    <label for="name">Task Name</label>
                    <input type="text" class="form-control" id="name" name="name" placeholder="Enter task name" required>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea class="form-control" id="description" name="description" placeholder="Task description" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="project">Project</label>
                    <select class="form-control" id="project" name="project">
                        <option value="">-- Select Project --</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="priority">Priority</label>
                    <select class="form-control" id="priority" name="priority">
                        <option value="">-- Select Priority --</option>
                        <option value="HIGH">High</option>
                        <option value="MEDIUM">Medium</option>
                        <option value="LOW">Low</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="deadline">Deadline</label>
                    <input type="datetime-local" class="form-control" id="deadline" name="deadline">
                </div>
                
                <div class="form-group">
                    <label for="taskStatus">Status</label>
                    <select class="form-control" id="taskStatus" name="taskStatus">
                        <option value="TODO">To Do</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="BLOCKED">Blocked</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="assignedTo">Assign To</label>
                    <select class="form-control" id="assignedTo" name="assignedTo">
                        <option value="">-- Select User --</option>
                    </select>
                </div>
                
              </div>
              <!-- /.card-body -->

              <div class="card-footer">
                <button type="submit" class="btn btn-primary" onclick="submit();">Submit</button>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/viewTask';">View Tasks</button>
              </div>
            </div>
            <!-- /.card -->
        </div>
      </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->
  <jsp:include page="/WEB-INF/views/layout/footer.jsp"></jsp:include>

<script type="text/javascript">
var projects = [];
var users = [];

$(document).ready(function() {
    loadProjects();
    loadUsers();
});

function loadProjects() {
    $.ajax({
        url: '${pageContext.request.contextPath}/allProject',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                projects = response.data;
                var projectSelect = $('#project');
                projectSelect.empty();
                projectSelect.append('<option value="">-- Select Project --</option>');
                $.each(projects, function(index, project) {
                    projectSelect.append('<option value="' + project.projectId + '">' + project.name + '</option>');
                });
            }
        }
    });
}

function loadUsers() {
    $.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                users = response.data;
                var userSelect = $('#assignedTo');
                userSelect.empty();
                userSelect.append('<option value="">-- Select User --</option>');
                $.each(users, function(index, user) {
                    userSelect.append('<option value="' + user.user_id + '">' + user.user_name + ' (' + user.email + ')</option>');
                });
            }
        }
    });
}

function submit() {
    var projectId = $('#project').val();
    var assignedUserId = $('#assignedTo').val();
    
    var taskData = {
        taskId: $('#taskId').val(),
        name: $('#name').val(),
        description: $('#description').val(),
        priority: $('#priority').val(),
        deadline: $('#deadline').val(),
        taskStatus: $('#taskStatus').val()
    };
    
    if (projectId) {
        taskData.project = { projectId: parseInt(projectId) };
    }
    
    if (assignedUserId) {
        taskData.assignedTo = { user_id: parseInt(assignedUserId) };
    }

    $.ajax({
        url: '${pageContext.request.contextPath}/saveTask',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(taskData),
        success: function(response) {
            alert(response.message);
            if (response.status === '200') {
                window.location.href = '${pageContext.request.contextPath}/viewTask';
            }
        },
        error: function(xhr) {
            alert('Error: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error'));
        }
    });
}
</script>
</body>
</html>
