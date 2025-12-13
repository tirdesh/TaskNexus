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
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                  <h3 class="card-title mb-2 mb-sm-0">All Tasks</h3>
                  <div>
                    <button id="addTaskBtn" class="btn btn-primary" style="display: none;" onclick="window.location.href='${pageContext.request.contextPath}/addTask?returnTo=viewTask';">Add Task</button>
                  </div>
                </div>
                <div class="mt-3">
                  <div class="form-row">
                    <div class="col-sm-3 mb-2">
                      <select id="filterProject" class="form-control">
                        <option value="">All Projects</option>
                      </select>
                    </div>
                    <div class="col-sm-3 mb-2">
                      <select id="filterAssignee" class="form-control">
                        <option value="">All Assignees</option>
                      </select>
                    </div>
                    <div class="col-sm-2 mb-2">
                      <select id="filterStatus" class="form-control">
                        <option value="">All Statuses</option>
                        <option value="TODO">To Do</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="BLOCKED">Blocked</option>
                      </select>
                    </div>
                    <div class="col-sm-2 mb-2">
                      <select id="filterPriority" class="form-control">
                        <option value="">All Priorities</option>
                        <option value="HIGH">High</option>
                        <option value="MEDIUM">Medium</option>
                        <option value="LOW">Low</option>
                      </select>
                    </div>
                    <div class="col-sm-2 mb-2">
                      <button class="btn btn-secondary btn-block" onclick="clearFilters()">Clear</button>
                    </div>
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
              <div class="card-footer clearfix">
                <ul class="pagination pagination-sm m-0 float-right">
                </ul>
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
var data = [];
var projects = [];
var users = [];
var currentPage = 1;

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
                        load(currentPage);
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

function edit(taskId) {
    if (taskId) {
        window.location.href = '${pageContext.request.contextPath}/addTask?taskId=' + taskId + '&returnTo=viewTask';
    }
}

function clearFilters() {
  $('#filterProject').val('');
  $('#filterAssignee').val('');
  $('#filterStatus').val('');
  $('#filterPriority').val('');
  // Note: active parameter is preserved automatically via URL parameter in load()
  load(1);
}

function renderTable(tasks) {
  var rows = tasks || [];
  $('#example1 tbody').empty();
  if (rows.length === 0) {
    return;
  }
  rows.forEach(function(task, i) {
    var row = '<tr class="tr">';
    row += '<td>' + (task.name || '') + '</td>';
    row += '<td>' + (task.description || '') + '</td>';
    row += '<td>' + (task.project ? task.project.name : 'N/A') + '</td>';
    row += '<td><span class="badge badge-' + getPriorityBadge(task.priority ? task.priority.name : '') + '">' + (task.priority ? (task.priority.name || task.priority) : 'N/A') + '</span></td>';
    row += '<td><span class="badge badge-primary">' + (task.taskStatus ? (task.taskStatus.name || task.taskStatus) : 'N/A') + '</span></td>';
    row += '<td>' + (task.assignedTo ? task.assignedTo.user_name : 'Unassigned') + '</td>';
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
    console.log('Task canDelete check:', task.taskId, 'canDelete:', task.canDelete, 'hasOwnProperty:', task.hasOwnProperty('canDelete'), 'final canDelete:', canDelete);
    if (canDelete) {
      console.log('Rendering delete button for task:', task.taskId);
      // Use only event delegation, no onclick to avoid double-firing
      row += '<a href="#" class="btn btn-sm btn-danger action-btn delete-task-btn" data-task-id="' + task.taskId + '" title="Delete Task" data-toggle="tooltip">';
      row += '<i class="fas fa-trash"></i>';
      row += '</a>';
    } else {
      console.log('NOT rendering delete button for task:', task.taskId, 'canDelete value:', task.canDelete);
    }
    row += '</div>';
    row += '</td>';
    row += '</tr>';
    $("#example1 tbody").append(row);
  });
}

function loadFiltersData() {
  $.ajax({
    url: 'allProject',
    type: 'GET',
    data: { page: 1, size: 1000 }, // Get all projects for filter dropdown
    success: function(response) {
      if (response.status === '200' && response.data) {
        projects = response.data;
        var sel = $('#filterProject');
        sel.empty();
        sel.append('<option value="">All Projects</option>');
        projects.forEach(function(p) {
          sel.append('<option value="' + p.projectId + '">' + p.name + '</option>');
        });
      }
    }
  });

  $.ajax({
    url: 'userList',
    type: 'GET',
    success: function(response) {
      if (response.status === '200' && response.data) {
        users = response.data;
        var sel = $('#filterAssignee');
        sel.empty();
        sel.append('<option value="">All Assignees</option>');
        users.forEach(function(u) {
          sel.append('<option value="' + u.user_id + '">' + u.user_name + '</option>');
        });
      }
    }
  });
}

function load(page) {
    currentPage = page;
    // Check if active parameter is in URL
    var urlParams = new URLSearchParams(window.location.search);
    var activeOnly = urlParams.get('active') === 'true';
    
    var filterData = {
        page: page,
        size: 5,
        projectId: $('#filterProject').val(),
        assigneeId: $('#filterAssignee').val(),
        status: $('#filterStatus').val(),
        priority: $('#filterPriority').val(),
        active: activeOnly
    };

    $.ajax({
        url: 'allTask',
        type: 'GET',
        data: filterData,
        success: function(response) {
            data = response.data || [];
            renderTable(data);
            
            // Initialize tooltips for action buttons
            $('[data-toggle="tooltip"]').tooltip();

            // Pagination
            var pagination = $('.pagination');
            pagination.empty();
            var totalPages = response.totalPages;

            if (totalPages > 1) {
                var prevClass = (currentPage === 1) ? "disabled" : "";
                pagination.append('<li class="page-item ' + prevClass + '"><a class="page-link" href="#" onclick="load(' + (currentPage - 1) + ')">&laquo;</a></li>');

                for (var i = 1; i <= totalPages; i++) {
                    var activeClass = (i === currentPage) ? "active" : "";
                    pagination.append('<li class="page-item ' + activeClass + '"><a class="page-link" href="#" onclick="load(' + i + ')">' + i + '</a></li>');
                }

                var nextClass = (currentPage === totalPages) ? "disabled" : "";
                pagination.append('<li class="page-item ' + nextClass + '"><a class="page-link" href="#" onclick="load(' + (currentPage + 1) + ')">&raquo;</a></li>');
            }
        }
    });
}

function getPriorityBadge(priority) {
    if (!priority) return 'secondary';
    if (priority.toUpperCase() === 'HIGH') return 'danger';
    if (priority.toUpperCase() === 'MEDIUM') return 'warning';
    if (priority.toUpperCase() === 'LOW') return 'info';
    return 'secondary';
}

$(document).ready(function() {
    // Check if we're viewing active tasks only
    var urlParams = new URLSearchParams(window.location.search);
    var activeOnly = urlParams.get('active') === 'true';
    
    if (activeOnly) {
        // Update page title to indicate active tasks
        $('h1.m-0').text('Active Tasks');
        $('h3.card-title').text('Active Tasks');
        // Optionally disable or hide COMPLETED status in filter
        $('#filterStatus option[value="COMPLETED"]').prop('disabled', true);
    }
    
    // Check if user can create tasks in any project before showing Add Task button
    if (window.currentUserPromise) {
        window.currentUserPromise.then(function(user) {
            if (user) {
                // Load projects to check if user can create tasks in any of them
                $.ajax({
                    url: 'allProject',
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
    
    $('#filterProject, #filterAssignee, #filterStatus, #filterPriority').on('change', () => load(1));
    
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

    loadFiltersData();
    load(1);
});
</script>
