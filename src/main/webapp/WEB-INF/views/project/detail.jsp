<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark" id="pageTitle">Project Details</h1>
          </div>
        </div>
      </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-md-8">
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Project Details</h3>
              </div>
              <div class="card-body" id="projectDetails">
                <p class="text-center">Loading project details...</p>
              </div>
            </div>
            
            <!-- Team Members Section -->
            <div class="card card-info">
              <div class="card-header">
                <h3 class="card-title">Team Members</h3>
              </div>
              <div class="card-body">
                <div id="teamMembersList"></div>
                <div class="form-group mt-3">
                  <select class="form-control" id="addMemberSelect">
                    <option value="">-- Select User to Add --</option>
                  </select>
                  <button class="btn btn-primary mt-2" onclick="addTeamMember()">Add Team Member</button>
                </div>
              </div>
            </div>
            
            <!-- Tasks Section -->
            <div class="card card-warning">
              <div class="card-header">
                <h3 class="card-title">Tasks</h3>
              </div>
              <div class="card-body">
                <div id="tasksList"></div>
                <a href="#" id="addTaskLink" class="btn btn-primary mt-2">Add New Task</a>
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
// Extract projectId from URL
var pathParts = window.location.pathname.split('/');
var projectId = pathParts[pathParts.length - 1];

// Wait for jQuery to be fully loaded
(function() {
    function initProjectDetail() {
        // Validate projectId
        if (!projectId || isNaN(projectId)) {
            console.error('Invalid project ID:', projectId);
            $('#projectDetails').html('<p class="text-danger">Invalid project ID</p>');
            return;
        }
        
        // Ensure jQuery is available
        if (typeof jQuery === 'undefined') {
            console.error('jQuery is not loaded');
            $('#projectDetails').html('<p class="text-danger">Error: jQuery not loaded</p>');
            return;
        }
        
        // Use jQuery ready to ensure DOM is loaded
        jQuery(document).ready(function($) {
            loadProjectDetails(projectId);
            loadTeamMembers(projectId);
            loadTasks(projectId);
            loadUsersForAdd();
            
            // Set Add Task link with projectId
            $('#addTaskLink').attr('href', '${pageContext.request.contextPath}/addTask?projectId=' + projectId);
        });
    }
    
    // Try to initialize immediately if jQuery is available
    if (typeof jQuery !== 'undefined') {
        initProjectDetail();
    } else {
        // Wait for window load event (all scripts should be loaded by then)
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

function loadProjectDetails(projectId) {
    if (!projectId) {
        $('#projectDetails').html('<p class="text-danger">Project ID is required</p>');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId,
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var project = response.data;
                
                // Update page title with project name
                if (project.name) {
                    $('#pageTitle').text(project.name);
                }
                
                var html = '<dl class="row">';
                html += '<dt class="col-sm-3">Name:</dt><dd class="col-sm-9">' + (project.name || '') + '</dd>';
                html += '<dt class="col-sm-3">Description:</dt><dd class="col-sm-9">' + (project.description || 'N/A') + '</dd>';
                html += '<dt class="col-sm-3">Status:</dt><dd class="col-sm-9"><span class="badge badge-primary">' + (project.projectStatus || 'N/A') + '</span></dd>';
                html += '<dt class="col-sm-3">Project Manager:</dt><dd class="col-sm-9">' + (project.projectManager ? project.projectManager.user_name : 'Not assigned') + '</dd>';
                html += '<dt class="col-sm-3">Created:</dt><dd class="col-sm-9">' + (project.createdAt || 'N/A') + '</dd>';
                html += '</dl>';
                html += '<div class="mt-3">';
                html += '<a href="${pageContext.request.contextPath}/addProject?projectId=' + project.projectId + '" class="btn btn-warning">Edit Project</a>';
                html += '</div>';
                $('#projectDetails').html(html);
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
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId + '/teamMembers',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var html = '';
                if (response.data.length === 0) {
                    html = '<p class="text-muted">No team members assigned yet.</p>';
                } else {
                    html = '<ul class="list-group">';
                    $.each(response.data, function(index, member) {
                        html += '<li class="list-group-item d-flex justify-content-between align-items-center">';
                        html += '<span>' + (member.user_name || '') + ' (' + (member.email || '') + ')</span>';
                        html += '<button class="btn btn-sm btn-danger" onclick="removeTeamMember(' + member.user_id + ')">Remove</button>';
                        html += '</li>';
                    });
                    html += '</ul>';
                }
                $('#teamMembersList').html(html);
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
    $.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var select = $('#addMemberSelect');
                select.empty();
                select.append('<option value="">-- Select User to Add --</option>');
                $.each(response.data, function(index, user) {
                    select.append('<option value="' + user.user_id + '">' + user.user_name + ' (' + user.email + ')</option>');
                });
            }
        }
    });
}

function addTeamMember() {
    var pathParts = window.location.pathname.split('/');
    var projectId = pathParts[pathParts.length - 1];
    
    var userId = $('#addMemberSelect').val();
    if (!userId) {
        alert('Please select a user');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId + '/addTeamMember',
        type: 'POST',
        data: { userId: userId },
        success: function(response) {
            if (response.status === '200') {
                $('#addMemberSelect').val('');
                var pathParts = window.location.pathname.split('/');
                var projectId = pathParts[pathParts.length - 1];
                loadTeamMembers(projectId);
                alert('Team member added successfully');
            } else {
                alert(response.message || 'Error adding team member');
            }
        }
    });
}

function removeTeamMember(userId) {
    var pathParts = window.location.pathname.split('/');
    var projectId = pathParts[pathParts.length - 1];
    
    if (!confirm('Remove this team member from the project?')) {
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId + '/removeTeamMember',
        type: 'POST',
        data: { userId: userId },
        success: function(response) {
            if (response.status === '200') {
                var pathParts = window.location.pathname.split('/');
                var projectId = pathParts[pathParts.length - 1];
                loadTeamMembers(projectId);
                alert('Team member removed successfully');
            } else {
                alert(response.message || 'Error removing team member');
            }
        }
    });
}

function loadTasks(projectId) {
    if (!projectId) return;
    
    $.ajax({
        url: '${pageContext.request.contextPath}/allTask',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var projectIdNum = parseInt(projectId);
                var projectTasks = response.data.filter(function(task) {
                    return task.project && task.project.projectId == projectIdNum;
                });
                
                var html = '';
                if (projectTasks.length === 0) {
                    html = '<p class="text-muted">No tasks for this project yet.</p>';
                } else {
                    html = '<table class="table table-sm table-bordered"><thead><tr><th>Name</th><th>Status</th><th>Priority</th><th>Assigned To</th><th>Actions</th></tr></thead><tbody>';
                    $.each(projectTasks, function(index, task) {
                        html += '<tr>';
                        html += '<td>' + (task.name || '') + '</td>';
                        html += '<td><span class="badge badge-primary">' + (task.taskStatus || 'N/A') + '</span></td>';
                        html += '<td><span class="badge badge-info">' + (task.priority || 'N/A') + '</span></td>';
                        html += '<td>' + (task.assignedTo ? task.assignedTo.user_name : 'Unassigned') + '</td>';
                        html += '<td><a href="${pageContext.request.contextPath}/task/' + task.taskId + '" class="btn btn-sm btn-info">View</a></td>';
                        html += '</tr>';
                    });
                    html += '</tbody></table>';
                }
                $('#tasksList').html(html);
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

