<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark" id="pageTitle">
              <i class="fas fa-project-diagram mr-2"></i>Project Details
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
            <!-- Project Information Card -->
            <div class="card card-primary card-outline">
              <div class="card-header">
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                  <h3 class="card-title mb-2 mb-sm-0">
                    <i class="fas fa-info-circle mr-2"></i>Project Information
                  </h3>
                  <div id="projectActions"></div>
                </div>
              </div>
              <div class="card-body" id="projectDetails">
                <p class="text-center">Loading project details...</p>
              </div>
            </div>
            
            <!-- Team Members Section -->
            <div class="card card-info card-outline">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fas fa-users mr-2"></i>Team Members
                </h3>
              </div>
              <div class="card-body">
                <div id="teamMembersList"></div>
                <div class="form-group mt-3" id="addTeamMemberSection" style="display: none;">
                  <label for="addMemberSelect" class="font-weight-bold">Add Team Member</label>
                  <div class="input-group">
                  <select class="form-control" id="addMemberSelect">
                    <option value="">-- Select User to Add --</option>
                  </select>
                    <div class="input-group-append">
                      <button class="btn btn-primary" onclick="addTeamMember()">
                        <i class="fas fa-user-plus mr-1"></i>Add
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Tasks Section -->
            <div class="card card-warning card-outline">
              <div class="card-header">
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                  <h3 class="card-title mb-2 mb-sm-0">
                    <i class="fas fa-tasks mr-2"></i>Tasks
                  </h3>
                  <a href="#" id="addTaskLink" class="btn btn-sm btn-primary" style="display: none;">
                    <i class="fas fa-plus-circle mr-1"></i>Add Task
                  </a>
                </div>
              </div>
              <div class="card-body">
                <div id="progressSummary" class="mb-4"></div>
                <div id="tasksList"></div>
              </div>
            </div>
        </div>
      </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->
  <jsp:include page="/WEB-INF/views/layout/footer.jsp"></jsp:include>

<script type="text/javascript">
var pathParts = window.location.pathname.split('/');
var projectId = pathParts[pathParts.length - 1];
var currentUser = null;
var currentProject = null; // Store project details for team member display

(function() {
    function initProjectDetail() {
        if (!projectId || isNaN(projectId)) {
            console.error('Invalid project ID:', projectId);
            $('#projectDetails').html('<p class="text-danger">Invalid project ID</p>');
            return;
        }
        
        if (typeof jQuery === 'undefined') {
            console.error('jQuery is not loaded');
            $('#projectDetails').html('<p class="text-danger">Error: jQuery not loaded</p>');
            return;
        }
        
        jQuery(document).ready(function($) {
            if (window.currentUserPromise) {
                window.currentUserPromise.then(function(user){
                    currentUser = user;
                    loadProjectDetails(projectId);
                    loadTeamMembers(projectId);
                    loadTasks(projectId);
                    loadUsersForAdd();
                });
            } else {
                loadProjectDetails(projectId);
                loadTeamMembers(projectId);
                loadTasks(projectId);
                loadUsersForAdd();
            }
            $('#addTaskLink').attr('href', '${pageContext.request.contextPath}/addTask?projectId=' + projectId + '&returnTo=project');
        });
    }
    
    if (typeof jQuery !== 'undefined') {
        initProjectDetail();
    } else {
        window.addEventListener('load', function() {
            if (typeof jQuery !== 'undefined') {
                initProjectDetail();
            } else {
                console.error('jQuery still not available after page load');
                $('#projectDetails').html('<p class="text-danger">Error: jQuery not available</p>');
            }
        });
    }
})();

function formatDate(dateValue) {
    if (!dateValue) return 'N/A';
    
    if (typeof dateValue === 'string') {
        try {
            var date = new Date(dateValue);
            if (isNaN(date.getTime())) return dateValue;
            return date.toLocaleString();
        } catch (e) {
            return dateValue;
        }
    }
    
    if (Array.isArray(dateValue)) {
        if (dateValue.length >= 3) {
            var year = dateValue[0];
            var month = String(dateValue[1] || 1).padStart(2, '0');
            var day = String(dateValue[2] || 1).padStart(2, '0');
            var hour = String(dateValue[3] || 0).padStart(2, '0');
            var minute = String(dateValue[4] || 0).padStart(2, '0');
            var second = dateValue[5] ? String(dateValue[5]).padStart(2, '0') : '00';
            
            if (dateValue.length >= 6) {
                return year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
            } else {
                return year + '-' + month + '-' + day;
            }
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

function loadProjectDetails(projectId) {
    if (!projectId) {
        $('#projectDetails').html('<p class="text-danger">Project ID is required</p>');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var project = response.data;
                
                if (project.name) {
                    $('#pageTitle').html('<i class="fas fa-project-diagram mr-2"></i>' + project.name);
                }
                
                var html = '<dl class="row mb-0">';
                html += '<dt class="col-sm-4"><i class="fas fa-tag mr-2 text-primary"></i>Name:</dt>';
                html += '<dd class="col-sm-8"><strong>' + (project.name || '') + '</strong></dd>';
                
                html += '<dt class="col-sm-4"><i class="fas fa-align-left mr-2 text-info"></i>Description:</dt>';
                html += '<dd class="col-sm-8">' + (project.description || '<span class="text-muted">N/A</span>') + '</dd>';
                
                html += '<dt class="col-sm-4"><i class="fas fa-flag mr-2 text-warning"></i>Status:</dt>';
                html += '<dd class="col-sm-8"><span class="badge badge-primary badge-lg">' + getEnumName(project.projectStatus) + '</span></dd>';
                
                html += '<dt class="col-sm-4"><i class="fas fa-user-tie mr-2 text-success"></i>Project Manager:</dt>';
                html += '<dd class="col-sm-8">' + (project.projectManager ? '<i class="fas fa-user mr-1"></i>' + project.projectManager.user_name : '<span class="text-muted">Not assigned</span>') + '</dd>';
                
                html += '<dt class="col-sm-4"><i class="fas fa-calendar-alt mr-2 text-secondary"></i>Created:</dt>';
                html += '<dd class="col-sm-8">' + formatDate(project.createdAt) + '</dd>';
                html += '</dl>';
                
                $('#projectDetails').html(html);
                
                // Only add edit button if user has permission
                var canEdit = project.canEdit === true;
                var actionsHtml = '';
                if (canEdit) {
                    actionsHtml += '<a id="editProjectBtn" href="${pageContext.request.contextPath}/addProject?projectId=' + project.projectId + '" class="btn btn-sm btn-warning">';
                    actionsHtml += '<i class="fas fa-edit mr-1"></i>Edit Project';
                    actionsHtml += '</a>';
                }
                $('#projectActions').html(actionsHtml);

                // Store project for use in other functions
                currentProject = project;
                
                // Use permission flags from backend - explicitly check for true
                var canEdit = project.canEdit === true;
                var canManageTeam = project.canManageTeam === true;
                var canCreateTask = project.canCreateTask === true;
                
                // Debug logging (can be removed in production)
                console.log('Project permissions:', {
                    canEdit: canEdit,
                    canManageTeam: canManageTeam,
                    canCreateTask: canCreateTask,
                    rawCanCreateTask: project.canCreateTask
                });
                
                // Show/hide team management UI based on permissions
                if (canManageTeam) {
                    $('#addTeamMemberSection').show();
                } else {
                    $('#addTeamMemberSection').hide();
                }
                
                // Show/hide add task link based on permissions
                if (canCreateTask) {
                    $('#addTaskLink').show();
                } else {
                    $('#addTaskLink').hide();
                }
                
                // Reload team members now that currentProject is set (so permissions are correct)
                loadTeamMembers(projectId);
            } else {
                $('#projectDetails').html('<p class="text-danger">' + (response.message || 'Project not found') + '</p>');
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading project details:', status, error, xhr);
            var errorMsg = 'Error loading project details';
            if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
            } else if (xhr.status === 0) {
                errorMsg = 'Network error - please check your connection';
            } else if (xhr.status === 404) {
                errorMsg = 'Project not found';
            } else if (xhr.status === 500) {
                errorMsg = 'Server error - please try again later';
            }
            $('#projectDetails').html('<p class="text-danger">' + errorMsg + '</p>');
        }
    });
}

function loadTeamMembers(projectId) {
    if (!projectId) return;
    
    // Load team members
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId + '/teamMembers',
        type: 'GET',
        success: function(response) {
            if (response.status === '200' && response.data) {
                // Check permission - use currentProject if available (set by loadProjectDetails)
                // This ensures we use the backend permission flag
                var canManageTeam = false;
                if (currentProject && currentProject.canManageTeam === true) {
                    canManageTeam = true;
                } else {
                    // Fallback: calculate permissions if currentProject not available yet
                    var isAdmin = currentUser && currentUser.role && currentUser.role.some(function(r){ return r && r.name === 'ROLE_ADMIN'; });
                    var isManager = $('#editProjectBtn').is(':visible');
                    canManageTeam = isAdmin || isManager;
                }
                
                var project = currentProject; // Use stored project details
                var html = '';
                if (response.data.length === 0) {
                    html = '<p class="text-muted text-center py-3"><i class="fas fa-users-slash mr-2"></i>No team members assigned yet.</p>';
                } else {
                    html = '<div class="list-group">';
                    $.each(response.data, function(index, member) {
                        html += '<div class="list-group-item d-flex justify-content-between align-items-center">';
                        html += '<div class="d-flex align-items-center">';
                        html += '<i class="fas fa-user-circle fa-lg text-primary mr-3"></i>';
                        html += '<div>';
                        html += '<strong>' + (member.user_name || '') + '</strong>';
                        // Check if this member is the Project Manager
                        var isProjectManager = project && project.projectManager && project.projectManager.user_id === member.user_id;
                        if (isProjectManager) {
                            html += '<br><small class="text-muted"><i class="fas fa-crown mr-1 text-warning"></i>Project Manager</small>';
                        }
                        html += '</div>';
                        html += '</div>';
                        // Only show remove button if user can manage team (PM or Admin) AND member is not the project manager
                        if (canManageTeam && !isProjectManager) {
                            html += '<button class="btn btn-sm btn-danger remove-member-btn action-btn" onclick="removeTeamMember(' + member.user_id + ')" title="Remove Member" data-toggle="tooltip">';
                            html += '<i class="fas fa-times"></i>';
                            html += '</button>';
                        }
                        html += '</div>';
                    });
                    html += '</div>';
                }
                $('#teamMembersList').html(html);
                
                // Initialize tooltips
                $('[data-toggle="tooltip"]').tooltip();
            } else {
                $('#teamMembersList').html('<p class="text-danger">' + (response.message || 'Error loading team members') + '</p>');
            }
        },
        error: function(xhr) {
            $('#teamMembersList').html('<p class="text-danger">Error loading team members</p>');
        }
    });
}

function loadUsersForAdd() {
    var pathParts = window.location.pathname.split('/');
    var projectId = pathParts[pathParts.length - 1];
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId + '/availableUsers',
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            var select = $('#addMemberSelect');
            select.empty();
            select.append('<option value="">-- Select User to Add --</option>');
            if (response.status === '200' && response.data) {
                $.each(response.data, function(index, user) {
                    select.append('<option value="' + user.user_id + '">' + user.user_name + '</option>');
                });
            } else {
                select.append('<option value=\"\">No users available</option>');
            }
        },
        error: function(xhr) {
            var select = $('#addMemberSelect');
            select.empty();
            select.append('<option value=\"\">Error loading users</option>');
        }
    });
}

function addTeamMember() {
    var pathParts = window.location.pathname.split('/');
    var projectId = pathParts[pathParts.length - 1];
    
    var userId = $('#addMemberSelect').val();
    if (!userId) {
        showWarning('Please select a user');
        return;
    }
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId + '/addTeamMember',
        type: 'PATCH',
        data: { userId: userId },
        beforeSend: function(xhr) {
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            } else if (csrfToken) {
                xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
            }
        },
        success: function(response) {
            if (response.status === '200') {
                $('#addMemberSelect').val('');
                var pathParts = window.location.pathname.split('/');
                var projectId = pathParts[pathParts.length - 1];
                loadTeamMembers(projectId);
                loadUsersForAdd();
                showSuccess('Team member added successfully');
            } else {
                showError(response.message || 'Error adding team member');
            }
        },
        error: function(xhr) {
            var errorMsg = 'Error adding team member: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error');
            if (xhr.status === 403 && errorMsg.includes('CSRF')) {
                errorMsg = 'CSRF token error. Please refresh the page and try again.';
            }
            showError(errorMsg);
        }
    });
}

function removeTeamMember(userId) {
    if (!userId) {
        console.error('removeTeamMember: No user ID provided');
        return;
    }
    
    var pathParts = window.location.pathname.split('/');
    var projectId = pathParts[pathParts.length - 1];
    
    if (!projectId) {
        console.error('removeTeamMember: Could not determine project ID');
        return;
    }
    
    // Prevent double execution
    if (window.removingTeamMember === userId) {
        console.log('removeTeamMember: Already processing removal for user:', userId);
        return;
    }
    window.removingTeamMember = userId;
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    // Use SweetAlert directly to avoid aria-hidden issues
    Swal.fire({
        title: 'Remove Team Member',
        text: 'Are you sure you want to remove this team member from the project?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, remove it!',
        cancelButtonText: 'Cancel',
        allowOutsideClick: false,
        allowEscapeKey: true
    }).then((result) => {
        window.removingTeamMember = null; // Reset flag
        // Check both isConfirmed (newer versions) and value (older versions) for compatibility
        var isConfirmed = result && (result.isConfirmed === true || result.value === true);
        if (isConfirmed) {
            $.ajax({
                url: '${pageContext.request.contextPath}/project/' + projectId + '/removeTeamMember',
                type: 'DELETE',
                data: { userId: userId },
                beforeSend: function(xhr) {
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    } else if (csrfToken) {
                        xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
                    }
                },
                success: function(response) {
                    if (response && response.status === '200') {
                        var pathParts = window.location.pathname.split('/');
                        var projectId = pathParts[pathParts.length - 1];
                        loadTeamMembers(projectId);
                        loadUsersForAdd();
                        // Show message (may include warning about last member)
                        showSuccess(response.message || 'Team member removed successfully');
                    } else {
                        showError(response && response.message ? response.message : 'Error removing team member');
                    }
                },
                error: function(xhr) {
                    var errorMsg = xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error';
                    if (xhr.status === 403 && errorMsg.includes('CSRF')) {
                        errorMsg = 'CSRF token error. Please refresh the page and try again.';
                    }
                    showError('Error removing team member: ' + errorMsg);
                }
            });
        } else {
            window.removingTeamMember = null;
        }
    });
}

function loadTasks(projectId) {
    if (!projectId) return;
    
    $.ajax({
        url: '${pageContext.request.contextPath}/allTask',
        type: 'GET',
        data: { 
            projectId: projectId,
            page: 1,
            size: 1000  // Get all tasks for this project
        },
        success: function(response) {
            if (response.status === '200' && response.data) {
                // Tasks are already filtered by projectId on the server side
                var projectTasks = response.data;
                
                // Progress calculation
                var total = projectTasks.length;
                var completed = projectTasks.filter(function(t) {
                    var status = t.taskStatus ? (t.taskStatus.name || t.taskStatus) : '';
                    return status === 'COMPLETED';
                }).length;
                var percent = total === 0 ? 0 : Math.round((completed / total) * 100);
                var progressHtml = '<div class="progress-info mb-3">';
                progressHtml += '<div class="d-flex justify-content-between align-items-center mb-2">';
                progressHtml += '<span class="font-weight-bold"><i class="fas fa-chart-line mr-2"></i>Task Progress</span>';
                progressHtml += '<span class="badge badge-success badge-lg">' + percent + '%</span>';
                progressHtml += '</div>';
                progressHtml += '<div class="progress" style="height: 25px;">';
                progressHtml += '<div class="progress-bar bg-success progress-bar-striped progress-bar-animated" role="progressbar" style="width: ' + percent + '%" aria-valuenow="' + percent + '" aria-valuemin="0" aria-valuemax="100">';
                progressHtml += '<span class="font-weight-bold">' + completed + ' / ' + total + ' completed</span>';
                progressHtml += '</div></div>';
                progressHtml += '</div>';
                $('#progressSummary').html(progressHtml);
                
                var html = '';
                if (projectTasks.length === 0) {
                    html = '<p class="text-muted text-center py-3"><i class="fas fa-tasks mr-2"></i>No tasks for this project yet.</p>';
                } else {
                    html = '<div class="table-responsive">';
                    html += '<table class="table table-hover table-sm">';
                    html += '<thead class="thead-light">';
                    html += '<tr>';
                    html += '<th><i class="fas fa-tag mr-1"></i>Task Name</th>';
                    html += '<th><i class="fas fa-flag mr-1"></i>Status</th>';
                    html += '<th><i class="fas fa-exclamation-circle mr-1"></i>Priority</th>';
                    html += '<th><i class="fas fa-user mr-1"></i>Assigned To</th>';
                    html += '<th class="text-center"><i class="fas fa-cog mr-1"></i>Actions</th>';
                    html += '</tr>';
                    html += '</thead><tbody>';
                    $.each(projectTasks, function(index, task) {
                        html += '<tr>';
                        html += '<td><strong>' + (task.name || '') + '</strong></td>';
                        html += '<td><span class="badge badge-primary badge-lg">' + getEnumName(task.taskStatus) + '</span></td>';
                        html += '<td><span class="badge badge-info badge-lg">' + getEnumName(task.priority) + '</span></td>';
                        html += '<td>' + (task.assignedTo ? '<i class="fas fa-user mr-1"></i>' + task.assignedTo.user_name : '<span class="text-muted">Unassigned</span>') + '</td>';
                        html += '<td class="text-center">';
                        html += '<a href="${pageContext.request.contextPath}/task/' + task.taskId + '" class="btn btn-sm btn-info action-btn" title="View Details" data-toggle="tooltip">';
                        html += '<i class="fas fa-eye"></i>';
                        html += '</a>';
                        html += '</td>';
                        html += '</tr>';
                    });
                    html += '</tbody></table>';
                    html += '</div>';
                }
                $('#tasksList').html(html);
                // Initialize tooltips for action buttons
                $('[data-toggle="tooltip"]').tooltip();
            } else {
                $('#tasksList').html('<p class="text-danger">' + (response.message || 'Error loading tasks') + '</p>');
            }
        },
        error: function(xhr) {
            $('#tasksList').html('<p class="text-danger">Error loading tasks</p>');
        }
    });
}
</script>

