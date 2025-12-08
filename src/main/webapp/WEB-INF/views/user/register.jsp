<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>TaskNexus | User Registration</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/adminlte.min.css">
  <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700" rel="stylesheet">
</head>
<body class="hold-transition register-page">
<div class="register-box">
  <div class="register-logo">
    <a href="${pageContext.request.contextPath}/register"><b>User</b>Registration</a>
  </div>
  <div class="card">
    <div class="card-body register-card-body">
      <p class="login-box-msg">Register to set your password</p>
      <p class="text-muted small">Your email must be added by an admin first. If you don't have an account, please contact your administrator.</p>

      <div id="errorMsg" class="alert alert-danger alert-dismissible fade show" role="alert" style="display:none;">
        <span id="errorText"></span>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <div id="successMsg" class="alert alert-success alert-dismissible fade show" role="alert" style="display:none;">
        <span id="successText"></span>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <form id="registerForm">
        <div class="input-group mb-3">
          <input type="email" class="form-control" id="email" name="email" placeholder="Email" required autofocus>
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-envelope"></span>
            </div>
          </div>
        </div>
        <div class="input-group mb-3">
          <input type="password" class="form-control" id="password" name="password" placeholder="Password" required>
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-lock"></span>
            </div>
          </div>
        </div>
        <div class="input-group mb-3">
          <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Confirm Password" required>
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-lock"></span>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col-12">
            <button type="submit" class="btn btn-primary btn-block">Register</button>
          </div>
        </div>
      </form>
      <p class="mt-3 mb-1">
        <a href="${pageContext.request.contextPath}/loginPage">Already registered? Login here</a>
      </p>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/plugins/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/adminlte.min.js"></script>
<script type="text/javascript">
$(document).ready(function() {
    $('#registerForm').on('submit', function(e) {
        e.preventDefault();
        
        var email = $('#email').val();
        var password = $('#password').val();
        var confirmPassword = $('#confirmPassword').val();
        
        if (password !== confirmPassword) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Passwords do not match');
            return;
        }
        
        $.ajax({
            url: '${pageContext.request.contextPath}/register',
            type: 'POST',
            data: { email: email, password: password, confirmPassword: confirmPassword },
            success: function(response) {
                if (response.status === '200') {
                    $('#errorMsg').hide();
                    $('#successMsg').show();
                    $('#successText').text(response.message);
                    setTimeout(function() {
                        window.location.href = '${pageContext.request.contextPath}/loginPage';
                    }, 2000);
                } else {
                    $('#successMsg').hide();
                    $('#errorMsg').show();
                    $('#errorText').text(response.message || 'Registration failed');
                }
            },
            error: function(xhr) {
                $('#successMsg').hide();
                $('#errorMsg').show();
                var errorMsg = 'Registration failed';
                if (xhr.responseJSON && xhr.responseJSON.message) {
                    errorMsg = xhr.responseJSON.message;
                }
                $('#errorText').text(errorMsg);
            }
        });
    });
});
</script>
</body>
</html>

