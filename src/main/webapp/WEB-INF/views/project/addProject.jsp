<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-md-12">
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
    loadUsers();
    
    // Check if editing existing project
    var urlParams = new URLSearchParams(window.location.search);
    var projectId = urlParams.get('projectId');
    if (projectId) {
        loadProjectForEdit(projectId);
    }
});

function loadUsers() {
    $.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                users = response.data;
                var managerSelect = $('#projectManager');
                var memberSelect = $('#teamMembers');
                
                managerSelect.empty();
                managerSelect.append('<option value="">-- Select Project Manager --</option>');
                
                memberSelect.empty();
                
                $.each(users, function(index, user) {
                    managerSelect.append('<option value="' + user.user_id + '">' + user.user_name + ' (' + user.email + ')</option>');
                    memberSelect.append('<option value="' + user.user_id + '">' + user.user_name + ' (' + user.email + ')</option>');
                });
            }
        }
    });
}

function loadProjectForEdit(projectId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/project/' + projectId,
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var project = response.data;
                
                // Populate form fields
                $('#projectId').val(project.projectId);
                $('#name').val(project.name || '');
                $('#description').val(project.description || '');
                
                if (project.projectStatus) {
                    $('#projectStatus').val(project.projectStatus);
                }
                
                // Set project manager
                if (project.projectManager && project.projectManager.user_id) {
                    $('#projectManager').val(project.projectManager.user_id);
                }
                
                // Load team members after users are loaded
                setTimeout(function() {
                    if (project.teamMembers && project.teamMembers.length > 0) {
                        var memberIds = project.teamMembers.map(function(member) {
                            return member.user_id.toString();
                        });
                        $('#teamMembers').val(memberIds);
                    }
                }, 500);
                
                // Update form title
                $('#formTitle').text('Edit Project');
            }
        },
        error: function(xhr) {
            alert('Error loading project: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error'));
        }
    });
}

function submit() {
    var managerId = $('#projectManager').val();
    var selectedMembers = $('#teamMembers').val() || [];
    
    var projectData = {
        projectId: $('#projectId').val(),
        name: $('#name').val(),
        description: $('#description').val(),
        projectStatus: $('#projectStatus').val()
    };
    
    if (managerId) {
        projectData.projectManager = { user_id: parseInt(managerId) };
    }
    
    // Note: Team members need to be added separately via API after project creation
    // as the saveProject endpoint doesn't handle nested collections well
    
    $.ajax({
        url: '${pageContext.request.contextPath}/saveProject',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(projectData),
        success: function(response) {
            if (response.status === '200') {
                // If we have a project ID and team members, add them
                var projectId = response.data && response.data.projectId ? response.data.projectId : $('#projectId').val();
                if (projectId && selectedMembers.length > 0) {
                    addTeamMembers(projectId, selectedMembers, function() {
                        alert(response.message);
                        window.location.href = '${pageContext.request.contextPath}/viewProject';
                    });
                } else {
                    alert(response.message);
                    window.location.href = '${pageContext.request.contextPath}/viewProject';
                }
            } else {
                alert(response.message || 'Error saving project');
            }
        },
        error: function(xhr) {
            alert('Error: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Unknown error'));
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
    
    $.each(memberIds, function(index, userId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/project/' + projectId + '/addTeamMember',
            type: 'POST',
            data: { userId: userId },
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
