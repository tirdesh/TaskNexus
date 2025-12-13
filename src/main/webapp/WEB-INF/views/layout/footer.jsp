<footer class="main-footer">
    <div class="d-flex flex-column flex-md-row align-items-center justify-content-between">
      <div class="mb-2 mb-md-0">
        <strong>Copyright &copy; 2025 <a href="${pageContext.request.contextPath}/page">TaskNexus</a>.</strong> All rights reserved.
      </div>
      <div class="d-flex align-items-center">
        <span class="text-muted mr-3">
          <i class="fas fa-shield-alt"></i>
        </span>
        <span class="d-none d-sm-inline">
          <b>Version</b> 1.0.0
        </span>
      </div>
    </div>
  </footer>

  <!-- Control Sidebar -->
  <aside class="control-sidebar control-sidebar-dark">
    <!-- Control sidebar content goes here -->
  </aside>
  <!-- /.control-sidebar -->
</div>
<!-- ./wrapper -->

<!-- jQuery -->
<script src="${pageContext.request.contextPath}/plugins/jquery/jquery.min.js"></script>
<!-- jQuery UI 1.11.4 -->
<script src="${pageContext.request.contextPath}/plugins/jquery-ui/jquery-ui.min.js"></script>
<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
<script>
  $.widget.bridge('uibutton', $.ui.button)
</script>
<!-- CSRF Token Setup for AJAX -->
<script>
  $(document).ajaxSend(function(e, xhr, options) {
    // Read CSRF token and header name from meta tags
    var token = $('meta[name="_csrf"]').attr('content');
    var headerName = $('meta[name="_csrf_header"]').attr('content');
    
    if (token && headerName) {
      xhr.setRequestHeader(headerName, token);
    } else if (token) {
      // Fallback to default header name if meta tag not found
      xhr.setRequestHeader("X-CSRF-TOKEN", token);
    }
  });
</script>
<!-- Current user helper for role-based UI -->
<script>
  window.currentUserPromise = window.currentUserPromise || $.getJSON("${pageContext.request.contextPath}/currentUser").then(
    function(resp){ return resp && resp.status === '200' ? resp.data : null; }
  ).catch(function(){ return null; });

  $(function() {
    window.currentUserPromise.then(function(user){
      if (!user) return;
      var hasRoles = Array.isArray(user.role) && user.role.length > 0;
      var isAdmin = hasRoles && user.role.some(function(r){ return r && (r.name === 'ROLE_ADMIN' || r.name === 'ADMIN' || r === 'ROLE_ADMIN'); });
      $('#nav-users').toggle(!!isAdmin);
    });
  });
</script>
<!-- Bootstrap 4 -->
<script src="${pageContext.request.contextPath}/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- overlayScrollbars -->
<script src="${pageContext.request.contextPath}/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
<!-- SweetAlert2 -->
<script src="${pageContext.request.contextPath}/plugins/sweetalert2/sweetalert2.min.js"></script>
<!-- AdminLTE App - AdminLTE 3.2.0 (CDN) -->
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<!-- Notification Helper Functions -->
<script>
  // Helper function for success notifications
  function showSuccess(message, title) {
    Swal.fire({
      icon: 'success',
      title: title || 'Success',
      text: message,
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true
    });
  }

  // Helper function for error notifications
  function showError(message, title) {
    Swal.fire({
      icon: 'error',
      title: title || 'Error',
      text: message,
      confirmButtonColor: '#3085d6'
    });
  }

  // Helper function for warning notifications
  function showWarning(message, title) {
    Swal.fire({
      icon: 'warning',
      title: title || 'Warning',
      text: message,
      confirmButtonColor: '#3085d6'
    });
  }

  // Helper function for info notifications
  function showInfo(message, title) {
    Swal.fire({
      icon: 'info',
      title: title || 'Information',
      text: message,
      confirmButtonColor: '#3085d6'
    });
  }

  // Helper function for confirmation dialogs
  function showConfirm(message, title, callback) {
    Swal.fire({
      title: title || 'Are you sure?',
      text: message,
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      confirmButtonText: 'Yes',
      cancelButtonText: 'No'
    }).then((result) => {
      if (result.isConfirmed && callback) {
        callback();
      }
    });
  }
</script>
</body>
</html>