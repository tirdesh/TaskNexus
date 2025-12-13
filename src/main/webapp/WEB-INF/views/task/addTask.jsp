<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">
              <i class="fas fa-tasks mr-2"></i><span id="pageTitle">Add Task</span>
            </h1>
          </div>
        </div>
      </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row justify-content-center">
        <div class="col-md-10 col-lg-8">
            <!-- general form elements -->
            <div class="card card-primary card-outline">
              <div class="card-header">
                <h3 class="card-title" id="formTitle">
                  <i class="fas fa-plus-circle mr-2"></i>Add Task
                </h3>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
                <input type="hidden" id="taskId">
                
                <div class="form-group">
                    <label for="name">
                      <i class="fas fa-tag mr-1 text-primary"></i>Task Name <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="name" name="name" placeholder="Enter task name (3-200 characters)" required minlength="3" maxlength="200">
                    <small class="form-text text-muted">Task name must be between 3 and 200 characters</small>
                    <div class="invalid-feedback">Task name must be between 3 and 200 characters</div>
                </div>
                
                <div class="form-group">
                    <label for="description">
                      <i class="fas fa-align-left mr-1 text-info"></i>Description
                    </label>
                    <textarea class="form-control" id="description" name="description" placeholder="Task description" rows="4" maxlength="5000"></textarea>
                    <small class="form-text text-muted">Description must not exceed 5000 characters</small>
                </div>
                
                <div class="row">
                  <div class="col-md-6">
                <div class="form-group">
                        <label for="project">
                          <i class="fas fa-project-diagram mr-1 text-success"></i>Project
                        </label>
                    <select class="form-control" id="project" name="project">
                        <option value="">-- Select Project --</option>
                    </select>
                </div>
                  </div>
                  <div class="col-md-6">
                <div class="form-group">
                        <label for="priority">
                          <i class="fas fa-exclamation-circle mr-1 text-warning"></i>Priority
                        </label>
                    <select class="form-control" id="priority" name="priority">
                        <option value="">-- Select Priority --</option>
                        <option value="HIGH">High</option>
                        <option value="MEDIUM">Medium</option>
                        <option value="LOW">Low</option>
                    </select>
                </div>
                  </div>
                </div>
                
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group">
                        <label for="deadline">
                          <i class="fas fa-calendar-alt mr-1 text-danger"></i>Deadline
                        </label>
                        <input type="datetime-local" class="form-control" id="deadline" name="deadline">
                    </div>
                  </div>
                  <div class="col-md-6">
                <div class="form-group">
                        <label for="taskStatus">
                          <i class="fas fa-flag mr-1 text-secondary"></i>Status
                        </label>
                    <select class="form-control" id="taskStatus" name="taskStatus">
                        <option value="TODO">To Do</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="BLOCKED">Blocked</option>
                    </select>
                    </div>
                  </div>
                </div>
                
                <div class="form-group">
                    <label for="assignedTo">
                      <i class="fas fa-user mr-1 text-primary"></i>Assign To
                    </label>
                    <select class="form-control" id="assignedTo" name="assignedTo">
                        <option value="">-- Select User --</option>
                    </select>
                    <small class="form-text text-muted">Select a project first to see available users</small>
                </div>
                
              </div>
              <!-- /.card-body -->

              <div class="card-footer">
                <button type="submit" class="btn btn-primary" onclick="submit();">
                  <i class="fas fa-save mr-1"></i>Submit
                </button>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/viewTask';">
                  <i class="fas fa-times mr-1"></i>Cancel
                </button>
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

$(document).ready(function() {
    var urlParams = new URLSearchParams(window.location.search);
    var taskId = urlParams.get('taskId');
    var projectIdFromUrl = urlParams.get('projectId');
    var returnTo = urlParams.get('returnTo'); // Store return page

    // Store returnTo in a variable accessible to submit function
    window.taskReturnTo = returnTo || 'viewTask'; // Default to viewTask

    initPage(taskId, projectIdFromUrl);
});

function initPage(taskId, projectIdFromUrl) {
    loadProjects(function() {
        if (projectIdFromUrl) {
            $('#project').val(projectIdFromUrl).trigger('change');
        }
        if (taskId) {
            loadTaskForEdit(taskId);
        }
    });

    $('#project').on('change', function() {
        loadUsersForProject($(this).val());
    });
}

function loadProjects(callback) {
    $.ajax({
        url: '${pageContext.request.contextPath}/allProject',
        type: 'GET',
        data: { page: 1, size: 1000 }, // Get all projects for dropdown
        success: function(response) {
            if (response.status === '200' && response.data) {
                projects = response.data;
                var projectSelect = $('#project');
                projectSelect.empty();
                projectSelect.append('<option value="">-- Select Project --</option>');
                // Only show projects where user can create tasks
                $.each(projects, function(index, project) {
                    // Filter: only show projects where canCreateTask is explicitly true
                    if (project.canCreateTask === true) {
                        projectSelect.append('<option value="' + project.projectId + '">' + project.name + '</option>');
                    }
                });
            }
        },
        complete: function() {
            if (callback) callback();
        }
    });
}

function loadUsersForProject(projectId) {
    var userSelect = $('#assignedTo');
    userSelect.empty();
    userSelect.append('<option value="">-- Select User --</option>');

    if (!projectId) {
        userSelect.append('<option value="">Select a project first</option>');
        return;
    }

    // Get project details to include Project Manager in assignee list
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId,
        type: 'GET',
        dataType: 'json',
        success: function(projectResponse) {
            if (projectResponse.status === '200' && projectResponse.data) {
                var project = projectResponse.data;
                var seen = {};
                
                // Add Project Manager first (if exists)
                if (project.projectManager && project.projectManager.user_id) {
                    var pm = project.projectManager;
                    seen[pm.user_id] = true;
                    userSelect.append('<option value="' + pm.user_id + '">' + pm.user_name + ' (Project Manager)</option>');
                }
                
                // Then add team members
                var endpoint = '${pageContext.request.contextPath}/project/' + projectId + '/teamMembers';
                $.ajax({
                    url: endpoint,
        type: 'GET',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var users = response.data;
                users.forEach(function(user) {
                    if (user && user.user_id && !seen[user.user_id]) {
                        seen[user.user_id] = true;
                        userSelect.append('<option value="' + user.user_id + '">' + user.user_name + '</option>');
                                }
                            });
                        }
                    },
                    error: function() {
                        // If team members endpoint fails, at least we have PM
                    }
                });
            }
        },
        error: function() {
            userSelect.append('<option value="">Could not load users</option>');
        }
    });
}

function loadTaskForEdit(taskId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/task/' + taskId,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var task = response.data;
                
                $('#taskId').val(task.taskId);
                $('#name').val(task.name || '');
                $('#description').val(task.description || '');
                
                if (task.priority) {
                    var priorityValue = typeof task.priority === 'string' ? task.priority : (task.priority.name || task.priority);
                    $('#priority').val(priorityValue);
                }
                
                if (task.taskStatus) {
                    var statusValue = typeof task.taskStatus === 'string' ? task.taskStatus : (task.taskStatus.name || task.taskStatus);
                    $('#taskStatus').val(statusValue);
                }
                
                if (task.project && task.project.projectId) {
                    $('#project').val(task.project.projectId).trigger('change');
                }
                
                // Use a timeout to ensure users are loaded before setting the value
                setTimeout(function() {
                    if (task.assignedTo && task.assignedTo.user_id) {
                        $('#assignedTo').val(task.assignedTo.user_id);
                    }
                }, 500);
                
                if (task.deadline) {
                    var deadline = new Date(task.deadline);
                    if (!isNaN(deadline.getTime())) {
                        var year = deadline.getFullYear();
                        var month = String(deadline.getMonth() + 1).padStart(2, '0');
                        var day = String(deadline.getDate()).padStart(2, '0');
                        var hours = String(deadline.getHours()).padStart(2, '0');
                        var minutes = String(deadline.getMinutes()).padStart(2, '0');
                        $('#deadline').val(year + '-' + month + '-' + day + 'T' + hours + ':' + minutes);
                    }
                }
                
                $('#formTitle').html('<i class="fas fa-edit mr-2"></i>Edit Task');
                $('#pageTitle').text('Edit Task');
            }
        },
        error: function(xhr) {
            showError('Error loading task: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error'));
        }
    });
}

function submit() {
    // Client-side validation
    var taskName = $('#name').val().trim();
    if (!taskName) {
        showError('Task name is required');
        $('#name').focus();
        return;
    }
    if (taskName.length < 3) {
        showError('Task name must be at least 3 characters long');
        $('#name').focus();
        return;
    }
    if (taskName.length > 200) {
        showError('Task name must not exceed 200 characters');
        $('#name').focus();
        return;
    }
    
    var description = $('#description').val();
    if (description && description.length > 5000) {
        showError('Description must not exceed 5000 characters');
        $('#description').focus();
        return;
    }
    
    var projectId = $('#project').val();
    var assignedUserId = $('#assignedTo').val();
    var taskIdValue = $('#taskId').val();
    
    var taskData = {
        name: taskName,
        description: description || '',
        priority: $('#priority').val(),
        deadline: $('#deadline').val(),
        taskStatus: $('#taskStatus').val()
    };
    
    // Only include taskId if it's not empty
    if (taskIdValue && taskIdValue.trim() !== '') {
        taskData.taskId = taskIdValue;
    }
    
    if (projectId) {
        taskData.project = { projectId: parseInt(projectId) };
    }
    
    if (assignedUserId) {
        taskData.assignedTo = { user_id: parseInt(assignedUserId) };
    }

    var httpMethod = taskIdValue && taskIdValue.trim() !== '' ? 'PATCH' : 'POST';
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

    $.ajax({
        url: '${pageContext.request.contextPath}/saveTask',
        type: httpMethod,
        contentType: 'application/json',
        data: JSON.stringify(taskData),
        beforeSend: function(xhr) {
            // Ensure CSRF token is set in header (the global ajaxSend handler should also do this)
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            } else if (csrfToken) {
                xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
            }
        },
        success: function(response) {
            if (response.status === '200') {
                showSuccess(response.message);
                setTimeout(function() {
                    // Determine redirect URL based on returnTo parameter
                    var redirectUrl = '${pageContext.request.contextPath}/viewTask'; // Default
                    
                    if (window.taskReturnTo === 'project') {
                        // Get projectId from form or URL (form takes priority as user might have changed it)
                        var projectId = $('#project').val();
                        if (!projectId) {
                            projectId = new URLSearchParams(window.location.search).get('projectId');
                        }
                        if (projectId) {
                            redirectUrl = '${pageContext.request.contextPath}/project/' + projectId;
                        } else {
                            redirectUrl = '${pageContext.request.contextPath}/viewProject';
                        }
                    } else if (window.taskReturnTo === 'myTasks') {
                        redirectUrl = '${pageContext.request.contextPath}/myTasks';
                    } else if (window.taskReturnTo === 'taskDetail') {
                        // Return to the specific task detail page
                        var taskDetailId = new URLSearchParams(window.location.search).get('taskDetailId') || taskIdValue;
                        if (taskDetailId) {
                            redirectUrl = '${pageContext.request.contextPath}/task/' + taskDetailId;
                        } else {
                            redirectUrl = '${pageContext.request.contextPath}/viewTask';
                        }
                    } else if (window.taskReturnTo === 'viewTask' || !window.taskReturnTo) {
                        redirectUrl = '${pageContext.request.contextPath}/viewTask';
                    }
                    
                    window.location.href = redirectUrl;
                }, 1500);
            } else {
                showError(response.message);
            }
        },
        error: function(xhr) {
            console.error('SaveTask error:', xhr.status, xhr.responseText);
            var errorMsg = 'Error saving task';
            
            // Try to parse validation errors
            if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
                
                // Parse validation error messages
                if (errorMsg.includes('ConstraintViolation') || errorMsg.includes('Validation failed')) {
                    // Extract user-friendly message
                    if (errorMsg.includes('Task name is required')) {
                        errorMsg = 'Task name is required';
                    } else if (errorMsg.includes('must be between')) {
                        errorMsg = 'Task name must be between 3 and 200 characters';
                    } else if (errorMsg.includes('must not exceed')) {
                        if (errorMsg.includes('Description')) {
                            errorMsg = 'Description must not exceed 5000 characters';
                        } else {
                            errorMsg = 'Task name must not exceed 200 characters';
                        }
                    }
                }
                
                // Extract validation message from ConstraintViolationImpl format
                if (errorMsg.includes('ConstraintViolationImpl')) {
                    var match = errorMsg.match(/interpolatedMessage='([^']+)'/);
                    if (match && match[1]) {
                        errorMsg = match[1];
                    } else {
                        // Try alternative pattern
                        match = errorMsg.match(/messageTemplate='([^']+)'/);
                        if (match && match[1]) {
                            errorMsg = match[1].replace(/\{.*?\}/g, '').trim();
                        }
                    }
                }
            } else if (xhr.responseText) {
                try {
                    var error = JSON.parse(xhr.responseText);
                    if (error.message) {
                        errorMsg = error.message;
                        // Extract validation message from ConstraintViolationImpl format
                        if (errorMsg.includes('ConstraintViolationImpl')) {
                            var match = errorMsg.match(/interpolatedMessage='([^']+)'/);
                            if (match && match[1]) {
                                errorMsg = match[1];
                            }
                        }
                    }
                } catch(e) {
                    // If responseText contains validation error, try to extract it
                    var responseText = xhr.responseText;
                    if (responseText.includes('Task name must be between')) {
                        var match = responseText.match(/Task name must be between \d+ and \d+ characters/);
                        if (match) {
                            errorMsg = match[0];
                        } else {
                            errorMsg = 'Task name must be between 3 and 200 characters';
                        }
                    } else if (responseText.includes('Description must not exceed')) {
                        errorMsg = 'Description must not exceed 5000 characters';
                    } else if (responseText.includes('ConstraintViolationImpl')) {
                        // Try to extract from raw response text
                        var match = responseText.match(/interpolatedMessage='([^']+)'/);
                        if (match && match[1]) {
                            errorMsg = match[1];
                        } else {
                            errorMsg = 'Validation error: Please check your input';
                        }
                    } else {
                    errorMsg = 'Server error: ' + xhr.status;
                    }
                }
            }
            showError(errorMsg);
        }
    });
}
</script>
</body>
</html>
