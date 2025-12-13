<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>TaskNexus | User Registration</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <link rel="shortcut icon" type="image/png" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <style>
    body.register-page {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .register-box {
      width: 100%;
      max-width: 420px;
      margin: 0 auto;
    }
    .register-logo {
      text-align: center;
      margin-bottom: 2rem;
    }
    .register-logo a {
      text-decoration: none;
      color: #343a40;
    }
    .auth-logo-img {
      height: 80px;
      border-radius: 16px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.2);
      margin-bottom: 1rem;
      transition: transform 0.3s ease;
    }
    .auth-logo-img:hover {
      transform: scale(1.05);
    }
    .register-logo .h2 {
      color: #343a40;
      font-weight: 600;
      letter-spacing: 0.5px;
    }
    .register-logo .h2 b {
      font-weight: 700;
    }
    .register-box .card {
      border: none;
      border-radius: 1rem;
      box-shadow: 0 10px 40px rgba(0,0,0,0.15);
      overflow: hidden;
      background: #ffffff;
    }
    .register-card-body {
      padding: 2.5rem;
    }
    .login-box-msg {
      font-size: 1rem;
      color: #6c757d;
      margin-bottom: 1rem;
      text-align: center;
      font-weight: 500;
    }
    .text-muted.small {
      font-size: 0.875rem;
      margin-bottom: 1.5rem;
      text-align: center;
      color: #6c757d;
    }
    .input-group {
      margin-bottom: 1.25rem;
    }
    .form-control {
      border-radius: 0.5rem;
      border: 1px solid #dee2e6;
      padding: 0.75rem 1rem;
      font-size: 0.9375rem;
      transition: all 0.3s ease;
    }
    .form-control:focus {
      border-color: #007bff;
      box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
      outline: none;
    }
    .input-group-text {
      background-color: #f8f9fa;
      border: 1px solid #dee2e6;
      border-left: none;
      border-radius: 0 0.5rem 0.5rem 0;
      color: #6c757d;
    }
    .input-group .form-control:first-child {
      border-right: none;
      border-radius: 0.5rem 0 0 0.5rem;
    }
    .input-group .form-control:focus + .input-group-append .input-group-text {
      border-color: #007bff;
      background-color: #ffffff;
    }
    .btn-primary {
      border-radius: 0.5rem;
      padding: 0.75rem;
      font-weight: 600;
      font-size: 1rem;
      transition: all 0.3s ease;
    }
    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
    }
    .alert {
      border-radius: 0.5rem;
      border: none;
      margin-bottom: 1.5rem;
    }
    .register-card-body p.mt-3 {
      text-align: center;
      margin-top: 1.5rem;
      margin-bottom: 0;
    }
    .register-card-body p.mt-3 a {
      color: #007bff;
      text-decoration: none;
      font-weight: 500;
      transition: all 0.2s ease;
    }
    .register-card-body p.mt-3 a:hover {
      color: #0056b3;
      text-decoration: underline;
    }
    @media (max-width: 576px) {
      .register-card-body {
        padding: 2rem 1.5rem;
      }
      .register-box {
        padding: 1rem;
      }
    }
  </style>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/adminlte.min.css">
  <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700" rel="stylesheet">
</head>
<body class="hold-transition register-page">
<div class="register-box">
  <div class="register-logo">
    <a href="${pageContext.request.contextPath}/register">
      <img src="${pageContext.request.contextPath}/dist/img/Logo.png" alt="TaskNexus Logo" class="auth-logo-img"><br>
      <span class="h2"><b>User</b>Registration</span>
    </a>
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
        <a href="${pageContext.request.contextPath}/loginPage">
          <i class="fas fa-sign-in-alt mr-1"></i>Already registered? Login here
        </a>
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
        
        // Client-side validation
        var email = $('#email').val().trim();
        if (!email) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Email is required');
            $('#email').focus();
            return;
        }
        
        if (email.length > 100) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Email must not exceed 100 characters');
            $('#email').focus();
            return;
        }
        
        // Basic email format validation
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Please enter a valid email address');
            $('#email').focus();
            return;
        }
        
        var password = $('#password').val();
        if (!password) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Password is required');
            $('#password').focus();
            return;
        }
        
        if (password.length < 6) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Password must be at least 6 characters long');
            $('#password').focus();
            return;
        }
        
        // Password max length (reasonable limit, though not in entity)
        if (password.length > 100) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Password must not exceed 100 characters');
            $('#password').focus();
            return;
        }
        
        var confirmPassword = $('#confirmPassword').val();
        if (!confirmPassword) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Please confirm your password');
            $('#confirmPassword').focus();
            return;
        }
        
        if (password !== confirmPassword) {
            $('#successMsg').hide();
            $('#errorMsg').show();
            $('#errorText').text('Passwords do not match');
            $('#confirmPassword').focus();
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
                    // Parse validation error messages
                    if (errorMsg.includes('ConstraintViolation') || errorMsg.includes('Validation failed')) {
                        if (errorMsg.includes('Email should be valid') || errorMsg.includes('valid email')) {
                            errorMsg = 'Please enter a valid email address';
                        } else if (errorMsg.includes('Email is required')) {
                            errorMsg = 'Email is required';
                        } else if (errorMsg.includes('must not exceed')) {
                            errorMsg = 'Email must not exceed 100 characters';
                        }
                    }
                } else if (xhr.status === 400) {
                    errorMsg = 'Invalid input. Please check your data and try again.';
                } else if (xhr.status === 404) {
                    errorMsg = 'Email not found in system. Please contact your administrator to add your email first.';
                } else if (xhr.status === 409) {
                    errorMsg = 'User already registered. Please login instead.';
                }
                $('#errorText').text(errorMsg);
            }
        });
    });
});
</script>
</body>
</html>

