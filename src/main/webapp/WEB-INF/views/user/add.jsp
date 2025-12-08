  <jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>
    <!-- Main content -->
    <section class="content">
       <div class="container-fluid">
        <div class="row">
        <div class="col-md-12">
            <!-- general form elements -->
            <div class="card card-primary">
              <div class="card-header">
                <h3 class="card-title">Add User</h3>
              </div>
              <!-- /.card-header -->
                <div class="card-body">
                <input type="hidden" name="userId" id="userId">
                
                <div class="form-group">
                    <label for="name">Name</label>
                    <input type="text" class="form-control" required id="name" name="name" placeholder="Enter name">
                </div>
                
                  <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" class="form-control" required id="email" name="email" placeholder="Email">
                    <small class="form-text text-muted">User will register themselves using this email to set their password. Roles (Project Manager or Team Member) will be assigned when adding users to projects.</small>
                  </div>
                  
                </div>
                <!-- /.card-body -->

                <div class="card-footer">
                <button type="submit" class="btn btn-primary" onclick="submit();">Submit</button>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/viewUser';">View Users</button>
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
var editingUser = null;

$(document).ready(function() {
    // Check if editing existing user
    var urlParams = new URLSearchParams(window.location.search);
    var userId = urlParams.get('userId');
    if (userId) {
        loadUserForEdit(userId);
    }
});

function loadUserForEdit(userId) {
	$.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'POST',
        success: function(response) {
            if (response.status === '200' && response.data) {
                var user = response.data.find(function(u) {
                    return u.user_id == userId;
                });
                if (user) {
                    editingUser = user;
                    populateForm(user);
                }
            }
	}
	});
	}

function populateForm(user) {
    $('#userId').val(user.user_id);
    $('#name').val(user.user_name);
    $('#email').val(user.email);
    
    // Update form title
    $('.card-title').text('Edit User');
}

function submit() {
    var userData = {
        userId: $('#userId').val(),
        name: $('#name').val(),
        email: $('#email').val()
        // No roles - roles are assigned at project level
    };

$.ajax({
        url: '${pageContext.request.contextPath}/saveOrUpdate',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(userData),
        success: function(response) {
            if (response.status === '200') {
alert(response.message);
                window.location.href = '${pageContext.request.contextPath}/viewUser';
            } else {
                alert(response.message || 'Error saving user');
            }
        },
        error: function(xhr) {
            var errorMsg = 'Error saving user';
            if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
            }
            alert(errorMsg);
}
});
}

function edit(index) {
    if (!data || !data[index]) {
        alert('User data not available');
        return;
    }
    
    var user = data[index];
    $('#userId').val(user.user_id);
    $('#name').val(user.user_name);
    $('#email').val(user.email);
    
    // Scroll to form
    $('html, body').animate({
        scrollTop: $('.card-primary').offset().top
    }, 500);
}

function delete_(id) {
    if (!confirm('Are you sure you want to delete this user?')) {
        return;
    }
    
$.ajax({
        url: '${pageContext.request.contextPath}/deleteUser',
        type: 'POST',
        data: { user_id: id },
        success: function(response) {
            alert(response.message);
            load();
        },
        error: function() {
            alert('Error deleting user');
}
});
}

</script>
</body>
</html>
