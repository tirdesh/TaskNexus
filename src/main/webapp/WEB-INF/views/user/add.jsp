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
    var urlParams = new URLSearchParams(window.location.search);
    var userId = urlParams.get('userId');
    if (userId) {
        loadUserForEdit(userId);
    }
});

function loadUserForEdit(userId) {
	$.ajax({
        url: '${pageContext.request.contextPath}/list',
        type: 'GET',
        dataType: 'json',
        data: { page: 1, size: 1000 }, // Get all users to find the one to edit
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
    
    $('.card-title').text('Edit User');
}

function submit() {
    // Client-side validation
    var name = $('#name').val().trim();
    if (!name) {
        showError('Name is required');
        $('#name').focus();
        return;
    }
    if (name.length < 2) {
        showError('Name must be at least 2 characters long');
        $('#name').focus();
        return;
    }
    if (name.length > 50) {
        showError('Name must not exceed 50 characters');
        $('#name').focus();
        return;
    }
    
    var email = $('#email').val().trim();
    if (!email) {
        showError('Email is required');
        $('#email').focus();
        return;
    }
    if (email.length > 100) {
        showError('Email must not exceed 100 characters');
        $('#email').focus();
        return;
    }
    // Basic email format validation
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        showError('Please enter a valid email address');
        $('#email').focus();
        return;
    }
    
    var userData = {
        userId: $('#userId').val(),
        name: name,
        email: email
    };

    var httpMethod = userData.userId ? 'PATCH' : 'POST';

    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

$.ajax({
        url: '${pageContext.request.contextPath}/saveOrUpdate',
        type: httpMethod,
        contentType: 'application/json',
        data: JSON.stringify(userData),
        beforeSend: function(xhr) {
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
                window.location.href = '${pageContext.request.contextPath}/viewUser';
                }, 1500);
            } else {
                showError(response.message || 'Error saving user');
            }
        },
        error: function(xhr) {
            var errorMsg = 'Error saving user';
            if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
                // Parse validation error messages
                if (errorMsg.includes('ConstraintViolation') || errorMsg.includes('Validation failed')) {
                    // Extract user-friendly message
                    if (errorMsg.includes('Email should be valid') || errorMsg.includes('valid email')) {
                        errorMsg = 'Please enter a valid email address';
                    } else if (errorMsg.includes('Email is required')) {
                        errorMsg = 'Email is required';
                    } else if (errorMsg.includes('Name is required')) {
                        errorMsg = 'Name is required';
                    } else if (errorMsg.includes('must be between')) {
                        // Extract the constraint message
                        var match = errorMsg.match(/must be between \d+ and \d+/);
                        if (match) {
                            errorMsg = 'Name ' + match[0] + ' characters';
                        }
                    }
                }
            } else if (xhr.status === 409) {
                errorMsg = 'Email already exists. Please use a different email.';
            } else if (xhr.status === 400) {
                errorMsg = 'Invalid input. Please check your data and try again.';
            } else if (xhr.status === 403 && xhr.responseJSON && xhr.responseJSON.message && xhr.responseJSON.message.includes('CSRF')) {
                errorMsg = 'CSRF token error. Please refresh the page and try again.';
            }
            showError(errorMsg);
        }
});
}

function edit(index) {
    if (!data || !data[index]) {
        showError('User data not available');
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
    if (!id) {
        console.error('delete_: No user ID provided');
        return;
    }
    
    // Prevent double execution
    if (window.deletingUser === id) {
        console.log('delete_: Already processing deletion for user:', id);
        return;
    }
    window.deletingUser = id;
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    
    // Use SweetAlert directly to avoid aria-hidden issues
    Swal.fire({
        title: 'Delete User',
        text: 'Are you sure you want to delete this user?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        cancelButtonText: 'Cancel',
        allowOutsideClick: false,
        allowEscapeKey: true
    }).then((result) => {
        window.deletingUser = null; // Reset flag
        // Check both isConfirmed (newer versions) and value (older versions) for compatibility
        var isConfirmed = result && (result.isConfirmed === true || result.value === true);
        if (isConfirmed) {
            $.ajax({
                url: '${pageContext.request.contextPath}/deleteUser',
                type: 'DELETE',
                data: { user_id: id },
                beforeSend: function(xhr) {
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    } else if (csrfToken) {
                        xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
                    }
                },
                success: function(response) {
                    if (response && response.status === '200') {
                        showSuccess(response.message || 'User deleted successfully');
                        load();
                    } else {
                        var errorMsg = response && response.message ? response.message : 'Error deleting user';
                        showError(errorMsg);
                    }
                },
                error: function(xhr) {
                    var errorMsg = 'Error deleting user';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMsg = xhr.responseJSON.message;
                    } else if (xhr.status === 403 && xhr.responseJSON && xhr.responseJSON.message && xhr.responseJSON.message.includes('CSRF')) {
                        errorMsg = 'CSRF token error. Please refresh the page and try again.';
                    }
                    showError(errorMsg);
                }
            });
        } else {
            window.deletingUser = null;
        }
    });
}

</script>
</body>
</html>
