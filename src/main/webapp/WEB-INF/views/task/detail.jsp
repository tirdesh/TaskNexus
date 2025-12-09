<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-md-8">
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Task Details</h3>
              </div>
              <div class="card-body" id="taskDetails">
                <p class="text-center">Loading task details...</p>
              </div>
            </div>
            
            <!-- Comments Section -->
            <div class="card card-info">
              <div class="card-header">
                <h3 class="card-title">Comments</h3>
              </div>
              <div class="card-body">
                <div id="commentsList"></div>
                <div class="form-group mt-3">
                  <textarea class="form-control" id="commentText" rows="3" placeholder="Add a comment..."></textarea>
                  <button class="btn btn-primary mt-2" onclick="addComment()">Add Comment</button>
                </div>
              </div>
            </div>
            
            <!-- Attachments Section -->
            <div class="card card-warning">
              <div class="card-header">
                <h3 class="card-title">Attachments</h3>
              </div>
              <div class="card-body">
                <div id="attachmentsList"></div>
                <div class="form-group mt-3">
                  <input type="file" class="form-control-file" id="attachmentFile">
                  <button class="btn btn-primary mt-2" onclick="uploadAttachment()">Upload Attachment</button>
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
var taskId = window.location.pathname.split('/').pop();

$(document).ready(function() {
    loadTaskDetails();
    loadComments();
    loadAttachments();
});

function loadTaskDetails() {
    $.ajax({
        url: '${pageContext.request.contextPath}/task/' + taskId,
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var task = response.data;
                var html = '<dl class="row">';
                html += '<dt class="col-sm-3">Name:</dt><dd class="col-sm-9">' + (task.name || '') + '</dd>';
                html += '<dt class="col-sm-3">Description:</dt><dd class="col-sm-9">' + (task.description || '') + '</dd>';
                html += '<dt class="col-sm-3">Project:</dt><dd class="col-sm-9">' + (task.project ? task.project.name : 'N/A') + '</dd>';
                html += '<dt class="col-sm-3">Priority:</dt><dd class="col-sm-9"><span class="badge badge-info">' + (task.priority || 'N/A') + '</span></dd>';
                html += '<dt class="col-sm-3">Status:</dt><dd class="col-sm-9"><span class="badge badge-primary">' + (task.taskStatus || 'N/A') + '</span></dd>';
                html += '<dt class="col-sm-3">Assigned To:</dt><dd class="col-sm-9">' + (task.assignedTo ? task.assignedTo.user_name : 'Unassigned') + '</dd>';
                html += '<dt class="col-sm-3">Deadline:</dt><dd class="col-sm-9">' + (task.deadline || 'N/A') + '</dd>';
                html += '<dt class="col-sm-3">Created:</dt><dd class="col-sm-9">' + (task.createdAt || 'N/A') + '</dd>';
                html += '</dl>';
                $('#taskDetails').html(html);
            } else {
                $('#taskDetails').html('<p class="text-danger">Task not found</p>');
            }
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
                    html = '<p>No comments yet.</p>';
                } else {
                    $.each(response.data, function(index, comment) {
                        html += '<div class="comment-box mb-3 p-3 border rounded">';
                        html += '<p>' + (comment.content || '') + '</p>';
                        html += '<small class="text-muted">By: ' + (comment.createdBy ? comment.createdBy.user_name : 'Unknown') + ' on ' + (comment.createdAt || '') + '</small>';
                        html += '</div>';
                    });
                }
                $('#commentsList').html(html);
            }
        }
    });
}

function addComment() {
    var content = $('#commentText').val();
    if (!content.trim()) {
        alert('Please enter a comment');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/tasks/' + taskId + '/comments',
        type: 'POST',
        data: { content: content },
        success: function(response) {
            if (response.status === '200') {
                $('#commentText').val('');
                loadComments();
                alert('Comment added successfully');
            } else {
                alert(response.message || 'Error adding comment');
            }
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
                    html = '<p>No attachments yet.</p>';
                } else {
                    html = '<ul class="list-group">';
                    $.each(response.data, function(index, attachment) {
                        html += '<li class="list-group-item d-flex justify-content-between align-items-center">';
                        html += '<span>' + (attachment.fileName || '') + ' (' + formatFileSize(attachment.fileSize) + ')</span>';
                        html += '<a href="${pageContext.request.contextPath}/attachments/' + attachment.attachmentId + '/download" class="btn btn-sm btn-primary">Download</a>';
                        html += '</li>';
                    });
                    html += '</ul>';
                }
                $('#attachmentsList').html(html);
            }
        }
    });
}

function uploadAttachment() {
    var fileInput = $('#attachmentFile')[0];
    if (!fileInput.files || fileInput.files.length === 0) {
        alert('Please select a file');
        return;
    }
    
    var formData = new FormData();
    formData.append('file', fileInput.files[0]);
    
    $.ajax({
        url: '${pageContext.request.contextPath}/tasks/' + taskId + '/attachments',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.status === '200') {
                $('#attachmentFile').val('');
                loadAttachments();
                alert('Attachment uploaded successfully');
            } else {
                alert(response.message || 'Error uploading attachment');
            }
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
</script>
</body>
</html>

