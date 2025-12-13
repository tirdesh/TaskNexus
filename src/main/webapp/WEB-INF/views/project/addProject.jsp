<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">
              <i class="fas fa-project-diagram mr-2"></i><span id="pageTitle">Add Project</span>
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
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title" id="formTitle">Add Project</h3>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
                <input type="hidden" id="projectId">
                
                <div class="form-group">
                    <label for="name">Project Name</label>
                    <input type="text" class="form-control" id="name" name="name" placeholder="Enter project name" required>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea class="form-control" id="description" name="description" placeholder="Project description" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="projectManager">Project Manager</label>
                    <select class="form-control" id="projectManager" name="projectManager">
                        <option value="">-- Select Project Manager --</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="projectStatus">Project Status</label>
                    <select class="form-control" id="projectStatus" name="projectStatus">
                        <option value="PLANNING">Planning</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="ON_HOLD">On Hold</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="teamMembers">Team Members</label>
                    <select class="form-control" id="teamMembers" name="teamMembers" multiple size="5">
                    </select>
                    <small class="form-text text-muted">Hold Ctrl/Cmd to select multiple members</small>
                </div>
                
              </div>
              <!-- /.card-body -->

              <div class="card-footer">
                <button type="submit" class="btn btn-primary" onclick="submit();">Submit</button>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/viewProject';">View Projects</button>
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
var users = [];

$(document).ready(function() {
    var urlParams = new URLSearchParams(window.location.search);
    var projectId = urlParams.get('projectId');

    // Ensure users are loaded before trying to set project manager/team members
    if (projectId) {
        loadUsers(function() {
            loadProjectForEdit(projectId);
        });
    } else {
        loadUsers();
    }
});

function loadUsers(callback) {
    $.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'GET',
        dataType: 'json',
        data: { page: 1, size: 1000 }, // Get all users (large size to get all)
        success: function(response) {
            if (response.status === '200' && response.data) {
                users = response.data;
                var managerSelect = $('#projectManager');
                var memberSelect = $('#teamMembers');
                
                managerSelect.empty();
                managerSelect.append('<option value="">-- Select Project Manager --</option>');
                
                memberSelect.empty();
                
                $.each(users, function(index, user) {
                    var isAdmin = false;
                    if (user.role && Array.isArray(user.role)) {
                        isAdmin = user.role.some(function(role) {
                            return role && role.name === 'ROLE_ADMIN';
                        });
                    }
                    if (!isAdmin) {
                        managerSelect.append('<option value="' + user.user_id + '">' + user.user_name + '</option>');
                        memberSelect.append('<option value="' + user.user_id + '">' + user.user_name + '</option>');
                    }
                });
                if (typeof callback === 'function') {
                    callback();
                }
            }
        },
        error: function(xhr) {
            console.error('Error loading users:', xhr);
            showError('Error loading users: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error'));
            if (typeof callback === 'function') {
                callback();
            }
        }
    });
}

function loadProjectForEdit(projectId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var project = response.data;
                
                $('#projectId').val(project.projectId);
                $('#name').val(project.name || '');
                $('#description').val(project.description || '');
                
                if (project.projectStatus) {
                    var statusValue = typeof project.projectStatus === 'string' 
                        ? project.projectStatus 
                        : (project.projectStatus.name || project.projectStatus);
                    $('#projectStatus').val(statusValue);
                }
                
                if (project.projectManager && project.projectManager.user_id) {
                    $('#projectManager').val(project.projectManager.user_id);
                }
                
                if (project.teamMembers && project.teamMembers.length > 0) {
                    var memberIds = project.teamMembers.map(function(member) {
                        return member.user_id.toString();
                    });
                    $('#teamMembers').val(memberIds);
                }
                
                $('#formTitle').text('Edit Project');
                $('#pageTitle').text('Edit Project');
            }
        },
        error: function(xhr) {
            console.error('Error loading project:', xhr);
            showError('Error loading project: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error'));
        }
    });
}

function submit() {
    // Client-side validation
    var name = $('#name').val().trim();
    if (!name) {
        showError('Project name is required');
        $('#name').focus();
        return;
    }
    if (name.length < 3) {
        showError('Project name must be at least 3 characters long');
        $('#name').focus();
        return;
    }
    if (name.length > 100) {
        showError('Project name must not exceed 100 characters');
        $('#name').focus();
        return;
    }
    
    var description = $('#description').val();
    if (description && description.length > 5000) {
        showError('Description must not exceed 5000 characters');
        $('#description').focus();
        return;
    }
    
    var managerId = $('#projectManager').val();
    var selectedMembers = $('#teamMembers').val() || [];
    
    var projectData = {
        projectId: $('#projectId').val(),
        name: name,
        description: description || '',
        projectStatus: $('#projectStatus').val()
    };
    
    if (managerId) {
        projectData.projectManager = { user_id: parseInt(managerId) };
    }
    
    var httpMethod = projectData.projectId ? 'PATCH' : 'POST';
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/saveProject',
        type: httpMethod,
        contentType: 'application/json',
        data: JSON.stringify(projectData),
        beforeSend: function(xhr) {
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            } else if (csrfToken) {
                xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
            }
        },
        success: function(response) {
            if (response.status === '200') {
                // If we have a project ID and team members, add them
                var projectId = response.data && response.data.projectId ? response.data.projectId : $('#projectId').val();
                if (projectId && selectedMembers.length > 0) {
                    addTeamMembers(projectId, selectedMembers, function() {
                        showSuccess(response.message);
                        setTimeout(function() {
                        window.location.href = '${pageContext.request.contextPath}/viewProject';
                        }, 1500);
                    });
                } else {
                    showSuccess(response.message);
                    setTimeout(function() {
                    window.location.href = '${pageContext.request.contextPath}/viewProject';
                    }, 1500);
                }
            } else {
                showError(response.message || 'Error saving project');
            }
        },
        error: function(xhr) {
            var errorMsg = 'Error saving project';
            if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
                // Parse validation error messages
                if (errorMsg.includes('ConstraintViolation') || errorMsg.includes('Validation failed')) {
                    // Extract user-friendly message
                    if (errorMsg.includes('Project name is required')) {
                        errorMsg = 'Project name is required';
                    } else if (errorMsg.includes('must be between')) {
                        errorMsg = 'Project name must be between 3 and 100 characters';
                    } else if (errorMsg.includes('must not exceed')) {
                        errorMsg = 'Description must not exceed 5000 characters';
                    }
                }
            } else if (xhr.status === 400) {
                errorMsg = 'Invalid input. Please check your data and try again.';
            } else if (xhr.status === 403 && xhr.responseJSON && xhr.responseJSON.message && xhr.responseJSON.message.includes('CSRF')) {
                errorMsg = 'CSRF token error. Please refresh the page and try again.';
            }
            showError(errorMsg);
        }
    });
}

function addTeamMembers(projectId, memberIds, callback) {
    var completed = 0;
    var total = memberIds.length;
    
    if (total === 0) {
        callback();
        return;
    }
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    $.each(memberIds, function(index, userId) {
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
                completed++;
                if (completed === total) {
                    callback();
                }
            },
            error: function() {
                completed++;
                if (completed === total) {
                    callback();
                }
            }
        });
    });
}
</script>
</body>
</html>
