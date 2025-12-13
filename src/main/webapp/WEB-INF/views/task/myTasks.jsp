<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">My Tasks</h1>
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
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                  <h3 class="card-title mb-2 mb-sm-0">My Tasks</h3>
                  <div>
                    <button id="addTaskBtn" class="btn btn-primary" style="display: none;" onclick="window.location.href='${pageContext.request.contextPath}/addTask?returnTo=myTasks';">Add Task</button>
                  </div>
                </div>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
                <table id="example1" class="table table-bordered table-striped">
                <thead>
                <tr>
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
              <div class="card-footer clearfix">
                <!-- Pagination can be added here if needed in the future -->
              </div>
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
function formatDate(dateValue) {
    if (!dateValue) return 'N/A';
    if (typeof dateValue === 'string') {
        try {
            var date = new Date(dateValue);
            if (isNaN(date.getTime())) return dateValue;
            return date.toLocaleString();
        } catch (e) { return dateValue; }
    }
    if (Array.isArray(dateValue)) {
        if (dateValue.length >= 3) {
            var d = new Date(dateValue[0], dateValue[1] - 1, dateValue[2], dateValue[3] || 0, dateValue[4] || 0, dateValue[5] || 0);
            return d.toLocaleString();
        }
        return 'N/A';
    }
    if (dateValue instanceof Date) {
        return dateValue.toLocaleString();
    }
    return 'N/A';
}

function getEnumName(enumValue) {
    if (!enumValue) return 'N/A';
    if (typeof enumValue === 'string') return enumValue;
    if (enumValue.name) return enumValue.name;
    if (typeof enumValue === 'object') return String(enumValue);
    return 'N/A';
}

function edit(taskId) {
    if (taskId) {
        window.location.href = '${pageContext.request.contextPath}/addTask?taskId=' + taskId + '&returnTo=myTasks';
    }
}

function deleteTask_(id){
    console.log('deleteTask_ called with id:', id);
    if (!id) {
        console.error('deleteTask_: No task ID provided');
        return;
    }
    
    // Prevent double execution
    if (window.deletingTask === id) {
        console.log('deleteTask_: Already processing deletion for task:', id);
        return;
    }
    window.deletingTask = id;
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    console.log('deleteTask_: CSRF token:', csrfToken ? 'found' : 'missing');
    
    // Use SweetAlert directly to avoid aria-hidden issues
    Swal.fire({
        title: 'Delete Task',
        text: 'Are you sure you want to delete this task?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        cancelButtonText: 'Cancel',
        allowOutsideClick: false,
        allowEscapeKey: true
    }).then((result) => {
        console.log('deleteTask_: SweetAlert result:', result);
        window.deletingTask = null; // Reset flag
        // Check both isConfirmed (newer versions) and value (older versions) for compatibility
        var isConfirmed = result && (result.isConfirmed === true || result.value === true);
        if (isConfirmed) {
            console.log('deleteTask_: Confirmation callback executed, proceeding with deletion');
            $.ajax({
                url: '${pageContext.request.contextPath}/deleteTask',
                type: 'DELETE',
                data: { taskId: id },
                beforeSend: function(xhr) {
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    } else if (csrfToken) {
                        xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
                    }
                },
                success: function(response){
                    console.log('deleteTask_: AJAX success, response:', response);
                    if (response && response.status === '200') {
                        showSuccess(response.message || 'Task deleted successfully');
                        loadMyTasks();
                    } else {
                        var errorMsg = response && response.message ? response.message : 'Error deleting task';
                        showError(errorMsg);
                    }
                },
                error: function(xhr) {
                    console.error('deleteTask_: AJAX error:', xhr);
                    var errorMsg = 'Error deleting task';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMsg = xhr.responseJSON.message;
                    } else if (xhr.status === 403) {
                        if (xhr.responseJSON && xhr.responseJSON.message && xhr.responseJSON.message.includes('CSRF')) {
                            errorMsg = 'CSRF token error. Please refresh the page and try again.';
                        } else {
                            errorMsg = 'Not authorized to delete this task. Only Project Managers and Administrators can delete tasks.';
                        }
                    } else if (xhr.status === 404) {
                        errorMsg = 'Task not found';
                    } else if (xhr.status === 500) {
                        errorMsg = 'Server error. Please try again later.';
                    }
                    showError(errorMsg);
                }
            });
        } else {
            console.log('deleteTask_: User cancelled deletion');
            window.deletingTask = null;
        }
    });
}

$(document).ready(function() {
    // Event delegation for delete buttons (primary method, no onclick handlers)
    $(document).on('click', '.delete-task-btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var taskId = $(this).data('task-id');
        console.log('Delete button clicked via event delegation, taskId:', taskId);
        if (taskId) {
            deleteTask_(taskId);
        }
        return false;
    });
    
    // Check if user can create tasks in any project before showing Add Task button
    if (window.currentUserPromise) {
        window.currentUserPromise.then(function(user) {
            if (user) {
                // Load projects to check if user can create tasks in any of them
                $.ajax({
                    url: '${pageContext.request.contextPath}/allProject',
                    type: 'GET',
                    data: { page: 1, size: 1000 },
                    success: function(response) {
                        if (response.status === '200' && response.data) {
                            var canCreateAnyTask = response.data.some(function(project) {
                                return project.canCreateTask === true;
                            });
                            if (canCreateAnyTask) {
                                $('#addTaskBtn').show();
                            }
                        }
                    }
                });
            }
        });
    }
    
    loadMyTasks();
});

function loadMyTasks() {
    $.ajax({
        url: '${pageContext.request.contextPath}/myTasks',
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var tbody = $('#tasksBody');
                tbody.empty();
                
                if (response.data.length === 0) {
                    tbody.append('<tr><td colspan="7" class="text-center">No tasks assigned to you</td></tr>');
                } else {
                    $.each(response.data, function(index, task) {
                        var row = '<tr class="tr">';
                        row += '<td>' + (task.name || '') + '</td>';
                        row += '<td>' + (task.description || '') + '</td>';
                        row += '<td>' + (task.project ? task.project.name : 'N/A') + '</td>';
                        var priorityName = getEnumName(task.priority);
                        row += '<td><span class="badge badge-' + getPriorityBadgeClass(priorityName) + '">' + priorityName + '</span></td>';
                        var taskStatusName = getEnumName(task.taskStatus);
                        // Use dropdown for status (users can update their own task status)
                        row += '<td><select class="form-control form-control-sm task-status" data-task-id="' + task.taskId + '">';
                        row += '<option value="TODO"' + (taskStatusName === 'TODO' ? ' selected' : '') + '>To Do</option>';
                        row += '<option value="IN_PROGRESS"' + (taskStatusName === 'IN_PROGRESS' ? ' selected' : '') + '>In Progress</option>';
                        row += '<option value="COMPLETED"' + (taskStatusName === 'COMPLETED' ? ' selected' : '') + '>Completed</option>';
                        row += '<option value="BLOCKED"' + (taskStatusName === 'BLOCKED' ? ' selected' : '') + '>Blocked</option>';
                        row += '</select></td>';
                        var deadlineDisplay = formatDate(task.deadline);
                        if (task.isOverdue) {
                            deadlineDisplay += ' <span class="badge badge-danger">OVERDUE</span>';
                        }
                        row += '<td>' + deadlineDisplay + '</td>';
                        row += '<td>';
                        row += '<div class="btn-group" role="group">';
                        row += '<a href="${pageContext.request.contextPath}/task/' + task.taskId + '" class="btn btn-sm btn-info action-btn" title="View Details" data-toggle="tooltip">';
                        row += '<i class="fas fa-eye"></i>';
                        row += '</a> ';
                        // Only show Edit button if user has permission
                        if (task.canEdit === true) {
                            row += '<a href="#" onclick="edit(' + task.taskId + '); return false;" class="btn btn-sm btn-warning action-btn" title="Edit Task" data-toggle="tooltip">';
                            row += '<i class="fas fa-edit"></i>';
                            row += '</a> ';
                        }
                        // Only show Delete button if user has permission
                        // Team members CANNOT delete tasks - only Admin and Project Managers can delete
                        // Explicitly check that canDelete is true (not just truthy)
                        var canDelete = task.hasOwnProperty('canDelete') && task.canDelete === true;
                        if (canDelete) {
                            // Use only event delegation, no onclick to avoid double-firing
                            row += '<a href="#" class="btn btn-sm btn-danger action-btn delete-task-btn" data-task-id="' + task.taskId + '" title="Delete Task" data-toggle="tooltip">';
                            row += '<i class="fas fa-trash"></i>';
                            row += '</a>';
                        }
                        row += '</div>';
                        row += '</td>';
                        row += '</tr>';
                        tbody.append(row);
                    });
                    
                    // Bind status change event
                    $('.task-status').on('change', function() {
                        var taskId = $(this).data('task-id');
                        var newStatus = $(this).val();
                        updateTaskStatus(taskId, newStatus);
                    });
                    
                    // Initialize tooltips for action buttons
                    $('[data-toggle="tooltip"]').tooltip();
                }
            } else {
                $('#tasksBody').html('<tr><td colspan="7" class="text-center">' + (response.message || 'Error loading tasks') + '</td></tr>');
            }
        },
        error: function(xhr) {
            $('#tasksBody').html('<tr><td colspan="7" class="text-center text-danger">Error loading tasks</td></tr>');
        }
    });
}

function getPriorityBadgeClass(priority) {
    if (!priority) return 'secondary';
    var priorityStr = typeof priority === 'string' ? priority : (priority.name || String(priority));
    if (priorityStr.toUpperCase() === 'HIGH') return 'danger';
    if (priorityStr.toUpperCase() === 'MEDIUM') return 'warning';
    if (priorityStr.toUpperCase() === 'LOW') return 'info';
    return 'secondary';
}

function updateTaskStatus(taskId, status) {
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/updateTaskStatus',
        type: 'PATCH',
        data: { taskId: taskId, status: status },
        beforeSend: function(xhr) {
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            } else if (csrfToken) {
                xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
            }
        },
        success: function(response) {
            if (response.status === '200') {
                showSuccess('Task status updated successfully');
            } else {
                showError(response.message || 'Error updating status');
                loadMyTasks(); // Reload to revert
            }
        },
        error: function(xhr) {
            var errorMsg = 'Error updating task status';
            if (xhr.status === 403 && xhr.responseJSON && xhr.responseJSON.message && xhr.responseJSON.message.includes('CSRF')) {
                errorMsg = 'CSRF token error. Please refresh the page and try again.';
            }
            showError(errorMsg);
            loadMyTasks(); // Reload to revert
        }
    });
}
</script>
</body>
</html>

