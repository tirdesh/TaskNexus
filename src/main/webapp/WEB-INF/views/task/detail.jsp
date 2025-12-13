<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Task Details</h1>
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
            <div class="card card-primary card-outline">
              <div class="card-header">
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                  <h3 class="card-title mb-2 mb-sm-0">Task Information</h3>
                <div>
                    <a id="editTaskLink" class="btn btn-sm btn-warning mr-2" style="display: none;">
                      <i class="fas fa-edit"></i> Edit Task
                    </a>
                    <a href="${pageContext.request.contextPath}/viewTask" class="btn btn-sm btn-secondary">
                      <i class="fas fa-arrow-left"></i> Back
                    </a>
                  </div>
                </div>
              </div>
              <div class="card-body" id="taskDetails">
                <p class="text-center">Loading task details...</p>
              </div>
            </div>
            
            <!-- Comments Section -->
            <div class="card card-info card-outline">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fas fa-comments mr-2"></i>Comments
                </h3>
              </div>
              <div class="card-body">
                <div id="commentsList"></div>
                <div class="form-group mt-3" id="commentForm" style="display: none;">
                  <textarea class="form-control" id="commentText" rows="3" placeholder="Add a comment..."></textarea>
                  <button class="btn btn-primary mt-2" onclick="addComment()">
                    <i class="fas fa-paper-plane mr-1"></i> Add Comment
                  </button>
                </div>
                <div id="commentPermissionMsg" class="alert alert-info mt-2" style="display: none;">
                  <i class="fas fa-info-circle mr-1"></i>
                  <small>You don't have permission to add comments to this task.</small>
                </div>
              </div>
            </div>
            
            <!-- Attachments Section -->
            <div class="card card-warning card-outline">
              <div class="card-header">
                <h3 class="card-title">
                  <i class="fas fa-paperclip mr-2"></i>Attachments
                </h3>
              </div>
              <div class="card-body">
                <div id="attachmentsList"></div>
                <div class="form-group mt-3" id="attachmentForm" style="display: none;">
                  <div class="custom-file mb-2">
                    <input type="file" class="custom-file-input" id="attachmentFile">
                    <label class="custom-file-label" for="attachmentFile">Choose file</label>
                  </div>
                  <button class="btn btn-primary" onclick="uploadAttachment()">
                    <i class="fas fa-upload mr-1"></i> Upload Attachment
                  </button>
                </div>
                <div id="attachmentPermissionMsg" class="alert alert-info mt-2" style="display: none;">
                  <i class="fas fa-info-circle mr-1"></i>
                  <small>You don't have permission to upload attachments to this task.</small>
                </div>
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
// XSS Protection: HTML escape function
function escapeHtml(text) {
    if (!text) return '';
    var map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, function(m) { return map[m]; });
}

var taskId = window.location.pathname.split('/').pop();
var currentUser = null;
var taskCanEdit = false; // Store task edit permission

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

$(document).ready(function() {
    // Set edit link to return to this task detail page after editing
    $('#editTaskLink').attr('href', '${pageContext.request.contextPath}/addTask?taskId=' + taskId + '&returnTo=taskDetail&taskDetailId=' + taskId);
    
    // Update custom file input label
    $('#attachmentFile').on('change', function() {
        var fileName = $(this).val().split('\\').pop();
        $(this).siblings('.custom-file-label').addClass('selected').html(fileName || 'Choose file');
    });
    
    if (window.currentUserPromise) {
        window.currentUserPromise.then(function(user){
            currentUser = user;
            loadTaskDetails();
            loadComments();
            loadAttachments();
        });
    } else {
        loadTaskDetails();
        loadComments();
        loadAttachments();
    }
});

function loadTaskDetails() {
    $.ajax({
        url: '${pageContext.request.contextPath}/task/' + taskId,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            // Debug: log full response
            console.log('Full task detail response:', response);
            console.log('Response keys:', Object.keys(response));
            
            if (response.status === '200' && response.data) {
                var task = response.data;
                var isOverdue = response.isOverdue || false;
                var html = '<dl class="row mb-0">';
                html += '<dt class="col-sm-4"><i class="fas fa-tag mr-2 text-primary"></i>Name:</dt><dd class="col-sm-8"><strong>' + escapeHtml(task.name || '') + '</strong></dd>';
                html += '<dt class="col-sm-4"><i class="fas fa-align-left mr-2 text-info"></i>Description:</dt><dd class="col-sm-8">' + escapeHtml(task.description || 'N/A') + '</dd>';
                html += '<dt class="col-sm-4"><i class="fas fa-project-diagram mr-2 text-success"></i>Project:</dt><dd class="col-sm-8">' + escapeHtml(task.project ? task.project.name : 'N/A') + '</dd>';
                html += '<dt class="col-sm-4"><i class="fas fa-flag mr-2 text-warning"></i>Priority:</dt><dd class="col-sm-8"><span class="badge badge-info badge-lg">' + escapeHtml(getEnumName(task.priority)) + '</span></dd>';
                html += '<dt class="col-sm-4"><i class="fas fa-tasks mr-2 text-primary"></i>Status:</dt><dd class="col-sm-8"><span class="badge badge-primary badge-lg">' + escapeHtml(getEnumName(task.taskStatus)) + '</span></dd>';
                html += '<dt class="col-sm-4"><i class="fas fa-user mr-2 text-secondary"></i>Assigned To:</dt><dd class="col-sm-8">' + escapeHtml(task.assignedTo ? task.assignedTo.user_name : '<span class="text-muted">Unassigned</span>') + '</dd>';
                var deadlineDisplay = formatDate(task.deadline);
                if (isOverdue) {
                    deadlineDisplay += ' <span class="badge badge-danger ml-2">OVERDUE</span>';
                }
                html += '<dt class="col-sm-4"><i class="fas fa-calendar-alt mr-2 text-danger"></i>Deadline:</dt><dd class="col-sm-8">' + deadlineDisplay + '</dd>';
                html += '<dt class="col-sm-4"><i class="fas fa-clock mr-2 text-muted"></i>Created:</dt><dd class="col-sm-8">' + formatDate(task.createdAt) + '</dd>';
                if (isOverdue) {
                    html += '<dt class="col-sm-4"></dt><dd class="col-sm-8"><div class="alert alert-warning alert-dismissible"><i class="fas fa-exclamation-triangle mr-2"></i>This task is overdue!</div></dd>';
                }
                html += '</dl>';
                $('#taskDetails').html(html);

                // Use backend permission flags if available, otherwise calculate
                var canEdit = false;
                var canCommentOrUpload = false;
                
                if (response.canEdit !== undefined) {
                    canEdit = response.canEdit === true;
                } else {
                    // Fallback: calculate permissions
                    var isAdmin = currentUser && currentUser.role && currentUser.role.some(function(r){ return r && r.name === 'ROLE_ADMIN'; });
                    var isManager = currentUser && task.project && task.project.projectManager && currentUser.user_id === task.project.projectManager.user_id;
                    var isAssignee = currentUser && task.assignedTo && currentUser.user_id === task.assignedTo.user_id;
                    canEdit = isAdmin || isManager || isAssignee;
                }
                
                if (response.canCommentOrUpload !== undefined && response.canCommentOrUpload !== null) {
                    canCommentOrUpload = response.canCommentOrUpload === true;
                } else {
                    // Fallback: calculate permissions (team members can comment/upload)
                    // Note: task.project.teamMembers might not be loaded, so we'll make a best-effort check
                    var isAdmin = currentUser && currentUser.role && currentUser.role.some(function(r){ return r && r.name === 'ROLE_ADMIN'; });
                    var isManager = currentUser && task.project && task.project.projectManager && currentUser.user_id === task.project.projectManager.user_id;
                    var isAssignee = currentUser && task.assignedTo && currentUser.user_id === task.assignedTo.user_id;
                    
                    // Try to check team membership from project data if available
                    var isTeamMember = false;
                    if (currentUser && task.project) {
                        if (task.project.teamMembers && Array.isArray(task.project.teamMembers)) {
                            isTeamMember = task.project.teamMembers.some(function(m){ 
                                return m && m.user_id && m.user_id === currentUser.user_id; 
                            });
                        } else if (currentProject && currentProject.teamMembers && Array.isArray(currentProject.teamMembers)) {
                            // Try using stored project data if available
                            isTeamMember = currentProject.teamMembers.some(function(m){ 
                                return m && m.user_id && m.user_id === currentUser.user_id; 
                            });
                        }
                    }
                    
                    canCommentOrUpload = isAdmin || isManager || isAssignee || isTeamMember;
                    console.warn('canCommentOrUpload not in response, using fallback calculation:', canCommentOrUpload);
                }
                
                // Debug logging
                console.log('Task permissions:', {
                    canEdit: canEdit,
                    canCommentOrUpload: canCommentOrUpload,
                    rawCanCommentOrUpload: response.canCommentOrUpload,
                    currentUser: currentUser ? currentUser.user_id : null,
                    taskProject: task.project ? task.project.projectId : null
                });
                
                // Store for use in other functions
                taskCanEdit = canEdit;
                
                // Edit button: only for users who can edit the task
                if (canEdit) {
                    $('#editTaskLink').show();
                } else {
                    $('#editTaskLink').hide();
                }
                
                // Comment and attachment forms: for users who can comment/upload (includes team members)
                if (canCommentOrUpload) {
                    console.log('Showing comment and attachment forms');
                    $('#commentForm').show();
                    $('#attachmentForm').show();
                    $('#commentPermissionMsg').hide();
                    $('#attachmentPermissionMsg').hide();
                } else {
                    console.log('Hiding comment and attachment forms - no permission');
                    $('#commentForm').hide();
                    $('#attachmentForm').hide();
                    $('#commentPermissionMsg').show();
                    $('#attachmentPermissionMsg').show();
                }
            } else {
                $('#taskDetails').html('<p class="text-danger">' + (response.message || 'Task not found') + '</p>');
            }
        },
        error: function(xhr) {
            var errorMsg = 'Error loading task details';
            if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
            }
            $('#taskDetails').html('<p class="text-danger">' + errorMsg + '</p>');
        }
    });
}

function loadComments() {
    $.ajax({
        url: '${pageContext.request.contextPath}/tasks/' + taskId + '/comments',
        type: 'GET',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var html = '';
                if (response.data.length === 0) {
                    html = '<p class="text-muted text-center py-3"><i class="fas fa-comment-slash mr-2"></i>No comments yet.</p>';
                } else {
                    $.each(response.data, function(index, comment) {
                        html += '<div class="comment-box mb-3 p-3 border rounded bg-light">';
                        html += '<div class="d-flex justify-content-between align-items-start mb-2">';
                        html += '<div class="flex-grow-1">';
                        html += '<p class="mb-1">' + escapeHtml(comment.content || '') + '</p>';
                        html += '<small class="text-muted"><i class="fas fa-user mr-1"></i>' + escapeHtml(comment.createdBy ? comment.createdBy.user_name : 'Unknown') + ' <i class="fas fa-clock ml-2 mr-1"></i>' + formatDate(comment.createdAt) + '</small>';
                        html += '</div>';
                        html += '</div>';
                        html += '</div>';
                    });
                }
                $('#commentsList').html(html);
            } else {
                $('#commentsList').html('<p class="text-danger">' + (response.message || 'Error loading comments') + '</p>');
            }
        },
        error: function(xhr) {
            $('#commentsList').html('<p class="text-danger">Error loading comments</p>');
        }
    });
}

function addComment() {
    var content = $('#commentText').val();
    if (!content || !content.trim()) {
        showWarning('Comment content is required');
        $('#commentText').focus();
        return;
    }
    
    var trimmedContent = content.trim();
    if (trimmedContent.length > 5000) {
        showError('Comment must not exceed 5000 characters');
        $('#commentText').focus();
        return;
    }
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/tasks/' + taskId + '/comments',
        type: 'POST',
        data: { content: trimmedContent },
        beforeSend: function(xhr) {
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            } else if (csrfToken) {
                xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
            }
        },
        success: function(response) {
            if (response.status === '200') {
                $('#commentText').val('');
                loadComments();
                showSuccess('Comment added successfully');
            } else {
                showError(response.message || 'Error adding comment');
            }
        },
        error: function(xhr) {
            console.error('Comment POST error:', xhr.status, xhr.responseText);
            var errorMsg = 'Error adding comment';
            if (xhr.responseJSON) {
                if (xhr.responseJSON.message) {
                    errorMsg = xhr.responseJSON.message;
                    // Parse validation error messages
                    if (errorMsg.includes('ConstraintViolation') || errorMsg.includes('Validation failed')) {
                        if (errorMsg.includes('Comment content is required')) {
                            errorMsg = 'Comment content is required';
                        } else if (errorMsg.includes('must not exceed')) {
                            errorMsg = 'Comment must not exceed 5000 characters';
                        }
                    }
                }
                if (xhr.responseJSON.debug) {
                    console.error('Debug info:', xhr.responseJSON.debug);
                    // Don't show debug info to users, just log it
                }
            } else if (xhr.status === 400) {
                errorMsg = 'Invalid input. Please check your comment and try again.';
            } else if (xhr.status === 403) {
                errorMsg = 'You are not authorized to add comments to this task.';
            } else if (xhr.responseText) {
                try {
                    var error = JSON.parse(xhr.responseText);
                    if (error.message) errorMsg = error.message;
                } catch(e) {
                    errorMsg = 'Server error: ' + xhr.status;
                }
            }
            if (xhr.status === 403 && errorMsg.includes('CSRF')) {
                errorMsg = 'CSRF token error. Please refresh the page and try again.';
            }
            showError(errorMsg);
        }
    });
}

function loadAttachments() {
    $.ajax({
        url: '${pageContext.request.contextPath}/tasks/' + taskId + '/attachments',
        type: 'GET',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var html = '';
                if (response.data.length === 0) {
                    html = '<p class="text-muted text-center py-3"><i class="fas fa-file-slash mr-2"></i>No attachments yet.</p>';
                } else {
                    html = '<div class="list-group">';
                    $.each(response.data, function(index, attachment) {
                        html += '<div class="list-group-item d-flex justify-content-between align-items-center">';
                        html += '<div class="d-flex align-items-center">';
                        html += '<i class="fas fa-file mr-2 text-primary"></i>';
                        html += '<div>';
                        html += '<strong>' + escapeHtml(attachment.fileName || '') + '</strong>';
                        html += '<br><small class="text-muted">' + formatFileSize(attachment.fileSize) + '</small>';
                        html += '</div>';
                        html += '</div>';
                        html += '<div>';
                        html += '<a href="${pageContext.request.contextPath}/attachments/' + attachment.attachmentId + '/download" class="btn btn-sm btn-primary mr-1"><i class="fas fa-download"></i> Download</a>';
                        // Show delete button if user can edit task (Admin/PM/Assignee) OR is the uploader
                        var canDelete = false;
                        if (response.canEdit === true || taskCanEdit) {
                            canDelete = true;
                        } else if (currentUser && attachment.uploadedBy && currentUser.user_id === attachment.uploadedBy.user_id) {
                            // Allow users to delete their own attachments even if they can't edit the task
                            canDelete = true;
                        }
                        if (canDelete) {
                            html += '<button class="btn btn-sm btn-danger" onclick="deleteAttachment(' + attachment.attachmentId + ')"><i class="fas fa-trash"></i> Delete</button>';
                        }
                        html += '</div>';
                        html += '</div>';
                    });
                    html += '</div>';
                }
                $('#attachmentsList').html(html);
            } else {
                $('#attachmentsList').html('<p class="text-danger">' + (response.message || 'Error loading attachments') + '</p>');
            }
        },
        error: function(xhr) {
            $('#attachmentsList').html('<p class="text-danger">Error loading attachments</p>');
        }
    });
}

function uploadAttachment() {
    var fileInput = $('#attachmentFile')[0];
    if (!fileInput.files || fileInput.files.length === 0) {
        showWarning('Please select a file');
        return;
    }
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    var formData = new FormData();
    formData.append('file', fileInput.files[0]);
    
    $.ajax({
        url: '${pageContext.request.contextPath}/tasks/' + taskId + '/attachments',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        beforeSend: function(xhr) {
            // Ensure CSRF token is set
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            } else if (csrfToken) {
                xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
            }
        },
        success: function(response) {
            if (response.status === '200') {
                $('#attachmentFile').val('');
                loadAttachments();
                showSuccess('Attachment uploaded successfully');
            } else {
                showError(response.message || 'Error uploading attachment');
            }
        },
        error: function(xhr) {
            console.error('Attachment POST error:', xhr.status, xhr.responseText);
            var errorMsg = 'Error uploading attachment';
            if (xhr.responseJSON) {
                if (xhr.responseJSON.message) {
                    errorMsg = xhr.responseJSON.message;
                }
                if (xhr.responseJSON.debug) {
                    console.error('Debug info:', xhr.responseJSON.debug);
                    errorMsg += '\n\nDebug: ' + xhr.responseJSON.debug;
                }
            } else if (xhr.responseText) {
                try {
                    var error = JSON.parse(xhr.responseText);
                    if (error.message) errorMsg = error.message;
                } catch(e) {
                    errorMsg = 'Server error: ' + xhr.status;
                }
            }
            if (xhr.status === 403 && errorMsg.includes('CSRF')) {
                errorMsg = 'CSRF token error. Please refresh the page and try again.';
            }
            showError(errorMsg);
        }
    });
}

function formatFileSize(bytes) {
    if (!bytes) return '0 Bytes';
    var k = 1024;
    var sizes = ['Bytes', 'KB', 'MB', 'GB'];
    var i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

function deleteAttachment(attachmentId) {
    if (!attachmentId) {
        console.error('deleteAttachment: No attachment ID provided');
        return;
    }
    
    // Prevent double execution
    if (window.deletingAttachment === attachmentId) {
        console.log('deleteAttachment: Already processing deletion for attachment:', attachmentId);
        return;
    }
    window.deletingAttachment = attachmentId;
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    // Use SweetAlert directly to avoid aria-hidden issues
    Swal.fire({
        title: 'Delete Attachment',
        text: 'Are you sure you want to delete this attachment?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        cancelButtonText: 'Cancel',
        allowOutsideClick: false,
        allowEscapeKey: true
    }).then((result) => {
        window.deletingAttachment = null; // Reset flag
        // Check both isConfirmed (newer versions) and value (older versions) for compatibility
        var isConfirmed = result && (result.isConfirmed === true || result.value === true);
        if (isConfirmed) {
            $.ajax({
                url: '${pageContext.request.contextPath}/attachments/' + attachmentId,
                type: 'DELETE',
                beforeSend: function(xhr) {
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    } else if (csrfToken) {
                        xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
                    }
                },
                success: function(response) {
                    if (response && response.status === '200') {
                        loadAttachments();
                        showSuccess('Attachment deleted successfully');
                    } else {
                        showError(response && response.message ? response.message : 'Error deleting attachment');
                    }
                },
                error: function(xhr) {
                    var errorMsg = 'Error deleting attachment';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMsg = xhr.responseJSON.message;
                    } else if (xhr.status === 403 && errorMsg.includes('CSRF')) {
                        errorMsg = 'CSRF token error. Please refresh the page and try again.';
                    }
                    showError(errorMsg);
                }
            });
        } else {
            window.deletingAttachment = null;
        }
    });
}
</script>
</body>
</html>

