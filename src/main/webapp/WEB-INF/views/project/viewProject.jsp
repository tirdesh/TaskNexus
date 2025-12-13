<jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>

    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0 text-dark">Projects</h1>
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
                  <h3 class="card-title mb-2 mb-sm-0">All Projects</h3>
                  <button id="addProjectBtn" class="btn btn-primary" style="display: none;" onclick="window.location.href='${pageContext.request.contextPath}/addProject';">Add Project</button>
                </div>
                <div class="mt-3">
                  <div class="form-row">
                    <div class="col-sm-4 mb-2">
                      <input type="text" id="searchInput" class="form-control" placeholder="Search by name or description...">
                    </div>
                    <div class="col-sm-2 mb-2">
                      <button class="btn btn-primary btn-block" onclick="handleSearch()">
                        <i class="fas fa-search"></i> Search
                      </button>
                    </div>
                    <div class="col-sm-2 mb-2">
                      <button class="btn btn-secondary btn-block" onclick="clearSearch()">Clear</button>
                    </div>
                  </div>
                </div>
              </div>
              <!-- /.card-header -->
              <div class="card-body">
              <table id="example1" class="table table-bordered table-striped">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Status</th>
                    <th>Project Manager</th>
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
var currentSearch = '';
var searchTimeout;

function getEnumName(enumValue) {
    if (!enumValue) return 'N/A';
    if (typeof enumValue === 'string') return enumValue;
    if (enumValue.name) return enumValue.name;
    if (typeof enumValue === 'object') return String(enumValue);
    return 'N/A';
}

function deleteProject_(id){
    console.log('deleteProject_ called with id:', id);
    if (!id) {
        console.error('deleteProject_: No project ID provided');
        return;
    }
    
    // Prevent double execution
    if (window.deletingProject === id) {
        console.log('deleteProject_: Already processing deletion for project:', id);
        return;
    }
    window.deletingProject = id;
    
    // Get CSRF token from meta tags
    var csrfToken = $('meta[name="_csrf"]').attr('content');
    var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
    console.log('deleteProject_: CSRF token:', csrfToken ? 'found' : 'missing');
    
    // Use SweetAlert directly to avoid aria-hidden issues
    Swal.fire({
        title: 'Delete Project',
        text: 'Are you sure you want to delete this project?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        cancelButtonText: 'Cancel',
        allowOutsideClick: false,
        allowEscapeKey: true
    }).then((result) => {
        console.log('deleteProject_: SweetAlert result:', result);
        window.deletingProject = null; // Reset flag
        // Check both isConfirmed (newer versions) and value (older versions) for compatibility
        var isConfirmed = result && (result.isConfirmed === true || result.value === true);
        if (isConfirmed) {
            console.log('deleteProject_: Confirmation callback executed, proceeding with deletion');
            $.ajax({
                url: '${pageContext.request.contextPath}/deleteProject',
                type: 'DELETE',
                data: { projectId: id },
                beforeSend: function(xhr) {
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    } else if (csrfToken) {
                        xhr.setRequestHeader("X-CSRF-TOKEN", csrfToken);
                    }
                },
                success: function(response){
                    console.log('deleteProject_: AJAX success, response:', response);
                    if (response && response.status === '200') {
                        showSuccess(response.message || 'Project deleted successfully');
                        load(1);
                    } else {
                        var errorMsg = response && response.message ? response.message : 'Error deleting project';
                        showError(errorMsg);
                    }
                },
                error: function(xhr) {
                    console.error('deleteProject_: AJAX error:', xhr);
                    var errorMsg = 'Error deleting project';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMsg = xhr.responseJSON.message;
                    } else if (xhr.status === 403) {
                        if (xhr.responseJSON && xhr.responseJSON.message && xhr.responseJSON.message.includes('CSRF')) {
                            errorMsg = 'CSRF token error. Please refresh the page and try again.';
                        } else {
                            errorMsg = 'Not authorized to delete this project. Only Administrators can delete projects.';
                        }
                    } else if (xhr.status === 404) {
                        errorMsg = 'Project not found';
                    } else if (xhr.status === 500) {
                        errorMsg = 'Server error. Please try again later.';
                    }
                    showError(errorMsg);
                }
            });
        } else {
            console.log('deleteProject_: User cancelled deletion');
        }
    });
}

function view(projectId) {
    if (projectId) {
        window.location.href = '${pageContext.request.contextPath}/project/' + projectId;
    }
}

function edit(projectId) {
    if (projectId) {
        window.location.href = '${pageContext.request.contextPath}/addProject?projectId=' + projectId;
    }
}

function handleSearch() {
    clearTimeout(searchTimeout); // Clear any pending debounced search
    var searchTerm = $('#searchInput').val().trim();
    currentSearch = searchTerm;
    console.log('Search triggered with term:', searchTerm);
    load(1);
}

function clearSearch() {
    $('#searchInput').val('');
    currentSearch = '';
    load(1);
}

function load(page) {
    var requestData = { 
        page: page, 
        size: 5 
    };
    
    if (currentSearch && currentSearch.trim() !== '') {
        requestData.search = currentSearch.trim();
    }
    
    $.ajax({
        url: 'allProject',
        type: 'GET',
        data: requestData,
        success: function(response) {
            console.log('Search request:', requestData);
            console.log('Response:', response);
            data = response.data;
            $('#example1 tbody').empty();
            if (response.data && response.data.length > 0) {
                for (var i = 0; i < response.data.length; i++) {
                    var project = response.data[i];
                    var row = '<tr class="tr">';
                    row += '<td>' + (project.projectId || '') + '</td>';
                    row += '<td>' + (project.name || '') + '</td>';
                    row += '<td>' + (project.description || '') + '</td>';
                    row += '<td><span class="badge badge-primary">' + getEnumName(project.projectStatus) + '</span></td>';
                    row += '<td>' + (project.projectManager ? project.projectManager.user_name : 'Not assigned') + '</td>';
                    row += '<td>';
                    row += '<div class="btn-group" role="group">';
                    row += '<a href="#" onclick="view(' + project.projectId + '); return false;" class="btn btn-sm btn-info action-btn" title="View Details" data-toggle="tooltip">';
                    row += '<i class="fas fa-eye"></i>';
                    row += '</a> ';
                    // Only show Edit button if user has permission
                    if (project.canEdit === true) {
                        row += '<a href="#" onclick="edit(' + project.projectId + '); return false;" class="btn btn-sm btn-warning action-btn" title="Edit Project" data-toggle="tooltip">';
                        row += '<i class="fas fa-edit"></i>';
                        row += '</a> ';
                    }
                    // Only show Delete button if user has permission
                    console.log('Project canDelete check:', project.projectId, 'canDelete:', project.canDelete, 'type:', typeof project.canDelete);
                    // Use hasOwnProperty check like we do for tasks
                    var canDeleteProject = project.hasOwnProperty('canDelete') && project.canDelete === true;
                    if (canDeleteProject) {
                        console.log('Rendering delete button for project:', project.projectId);
                        // Use only event delegation, no onclick to avoid double-firing
                        row += '<a href="#" class="btn btn-sm btn-danger action-btn delete-project-btn" data-project-id="' + project.projectId + '" title="Delete Project" data-toggle="tooltip">';
                        row += '<i class="fas fa-trash"></i>';
                        row += '</a>';
                    } else {
                        console.log('NOT rendering delete button for project:', project.projectId, 'canDelete value:', project.canDelete);
                    }
                    row += '</div>';
                    row += '</td>';
                    row += '</tr>';
                    $("#example1 tbody").append(row);
                }
                // Initialize tooltips for action buttons
                $('[data-toggle="tooltip"]').tooltip();
            } else {
                var noDataRow = '<tr><td colspan="6" class="text-center">No projects found</td></tr>';
                $("#example1 tbody").append(noDataRow);
            }

            // Pagination
            var pagination = $('.pagination');
            pagination.empty();
            var totalPages = response.totalPages;
            var currentPage = response.currentPage;

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
            } else if (totalPages === 0 && currentSearch) {
                pagination.append('<li class="page-item disabled"><span class="page-link">No results</span></li>');
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading projects:', error);
            console.error('Response:', xhr.responseText);
            showError('Error loading projects. Please try again.');
        }
    });
}

$(document).ready(function() {
    // Check if user is Admin before showing Add Project button
    if (window.currentUserPromise) {
        window.currentUserPromise.then(function(user) {
            if (user && user.role && Array.isArray(user.role)) {
                var isAdmin = user.role.some(function(r) {
                    return r && r.name === 'ROLE_ADMIN';
                });
                if (isAdmin) {
                    $('#addProjectBtn').show();
                }
            }
        });
    }
    
    load(1);
    
    // Event delegation for delete buttons (primary method, no onclick handlers)
    $(document).on('click', '.delete-project-btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var projectId = $(this).data('project-id');
        console.log('Delete button clicked via event delegation, projectId:', projectId);
        if (projectId) {
            deleteProject_(projectId);
        }
        return false;
    });
    
    // Search with debounce (500ms delay after user stops typing)
    $('#searchInput').on('keyup', function() {
        clearTimeout(searchTimeout);
        var searchTerm = $(this).val().trim();
        searchTimeout = setTimeout(function() {
            currentSearch = searchTerm;
            load(1);
        }, 500);
    });
    
    // Allow Enter key to trigger immediate search
    $('#searchInput').on('keypress', function(e) {
        if (e.which === 13) {
            e.preventDefault();
            clearTimeout(searchTimeout);
            handleSearch();
        }
    });
});
</script>
