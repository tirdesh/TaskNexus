<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Users</h1>
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
                <h3 class="card-title">All Users</h3>
                <button class="btn btn-primary float-sm-right" onclick="window.location.href='${pageContext.request.contextPath}/addUser';">Add User</button>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
                <table id="example1" class="table table-bordered table-striped">
                  <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Registered</th>
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
var currentPage = 1;

function deleteUser_(id){
    if (!id) {
        console.error('deleteUser_: No user ID provided');
        return;
    }
    
    // Prevent double execution
    if (window.deletingUser === id) {
        console.log('deleteUser_: Already processing deletion for user:', id);
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
                data: { userId: id },
                beforeSend: function(xhr) {
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    } else if (csrfToken) {
                        xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
                    }
                },
                success: function(response){
                    if (response && response.status === '200') {
                        showSuccess(response.message || 'User deleted successfully');
                        load(currentPage);
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

function edit(userId){
    if (userId) {
        window.location.href = '${pageContext.request.contextPath}/addUser?userId=' + userId;
    }
}

function load(page){
    currentPage = page;
    $.ajax({
        url: 'list',
        type: 'GET',
        data: { page: page, size: 5 },
        success: function(response){
            data = response.data;
            $('#example1 tbody').empty();
            if(response.data && response.data.length > 0) {
                for(var i=0; i<response.data.length; i++){
                    var user = response.data[i];
                    var isAdmin = false;
                    if (user.role && Array.isArray(user.role)) {
                        isAdmin = user.role.some(function(role) {
                            return role && role.name === 'ROLE_ADMIN';
                        });
                    }
                    if (isAdmin) continue; // Skip admin users

                    var isRegistered = user.isRegistered ? '<span class="badge badge-success">Registered</span>' : '<span class="badge badge-warning">Not Registered</span>';
                    var row = '<tr class="tr">';
                    row += '<td>' + (user.user_name || '') + '</td>';
                    row += '<td>' + (user.email || '') + '</td>';
                    row += '<td>' + isRegistered + '</td>';
                    row += '<td>';
                    row += '<a href="#" onclick="edit(' + user.user_id + '); return false;" class="btn btn-sm btn-warning">Edit</a> ';
                    row += '<a href="#" onclick="deleteUser_(' + user.user_id + '); return false;" class="btn btn-sm btn-danger">Delete</a>';
                    row += '</td>';
                    row += '</tr>';
                    $("#example1 tbody").append(row);
                }
            }

            // Pagination
            var pagination = $('.pagination');
            pagination.empty();
            var totalPages = response.totalPages;

            if (totalPages > 1) {
                // Previous button
                var prevClass = (currentPage === 1) ? "disabled" : "";
                pagination.append('<li class="page-item ' + prevClass + '"><a class="page-link" href="#" onclick="load(' + (currentPage - 1) + ')">&laquo;</a></li>');

                // Page numbers
                for (var i = 1; i <= totalPages; i++) {
                    var activeClass = (i === currentPage) ? "active" : "";
                    pagination.append('<li class="page-item ' + activeClass + '"><a class="page-link" href="#" onclick="load(' + i + ')">' + i + '</a></li>');
                }

                // Next button
                var nextClass = (currentPage === totalPages) ? "disabled" : "";
                pagination.append('<li class="page-item ' + nextClass + '"><a class="page-link" href="#" onclick="load(' + (currentPage + 1) + ')">&raquo;</a></li>');
            }
        }
    });
}

$(document).ready(function() {
    load(1);
});
</script>
