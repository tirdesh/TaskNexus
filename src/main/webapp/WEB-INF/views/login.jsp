<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>TaskNexus | Log in</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <link rel="shortcut icon" type="image/png" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <style>
    body.login-page {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .login-box {
      width: 100%;
      max-width: 420px;
      margin: 0 auto;
    }
    .login-logo {
      text-align: center;
      margin-bottom: 2rem;
    }
    .login-logo a {
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
    .login-logo .h2 {
      color: #343a40;
      font-weight: 600;
      letter-spacing: 0.5px;
    }
    .login-logo .h2 b {
      font-weight: 700;
    }
    .login-box .card {
      border: none;
      border-radius: 1rem;
      box-shadow: 0 10px 40px rgba(0,0,0,0.15);
      overflow: hidden;
      background: #ffffff;
    }
    .login-card-body {
      padding: 2.5rem;
    }
    .login-box-msg {
      font-size: 1rem;
      color: #6c757d;
      margin-bottom: 1.75rem;
      text-align: center;
      font-weight: 500;
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
    .login-card-body p.mt-3 {
      text-align: center;
      margin-top: 1.5rem;
      margin-bottom: 0;
    }
    .login-card-body p.mt-3 a {
      color: #007bff;
      text-decoration: none;
      font-weight: 500;
      transition: all 0.2s ease;
    }
    .login-card-body p.mt-3 a:hover {
      color: #0056b3;
      text-decoration: underline;
    }
    @media (max-width: 576px) {
      .login-card-body {
        padding: 2rem 1.5rem;
      }
      .login-box {
        padding: 1rem;
      }
    }
  </style>

  <!-- Font Awesome -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/fontawesome-free/css/all.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css">
  <!-- icheck bootstrap -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/adminlte.min.css">
  <!-- Google Font: Source Sans Pro -->
  <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700" rel="stylesheet">
</head>
<body class="hold-transition login-page">
<div class="login-box">
  <div class="login-logo">
    <a href="${pageContext.request.contextPath}/login">
      <img src="${pageContext.request.contextPath}/dist/img/Logo.png" alt="TaskNexus Logo" class="auth-logo-img"><br>
      <span class="h2"><b>Task</b>Nexus</span>
    </a>
  </div>
  <!-- /.login-logo -->
  <div class="card">
    <div class="card-body login-card-body">
      <p class="login-box-msg">Sign in to start your session</p>

      <c:if test="${not empty SPRING_SECURITY_LAST_EXCEPTION}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
          ${SPRING_SECURITY_LAST_EXCEPTION.message}
          <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="input-group mb-3">
          <input type="text" class="form-control" id="username" name="username" placeholder="Email" required autofocus>
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
        <div class="row">
          <div class="col-12">
            <button type="submit" class="btn btn-primary btn-block">Sign In</button>
          </div>
          <!-- /.col -->
        </div>
      </form>

      <p class="mt-3 mb-1">
        <a href="${pageContext.request.contextPath}/register">
          <i class="fas fa-user-plus mr-1"></i>Register a new account
        </a>
      </p>
    </div>
    <!-- /.login-card-body -->
  </div>
</div>
<!-- /.login-box -->

<!-- jQuery -->
<script src="${pageContext.request.contextPath}/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap 4 -->
<script src="${pageContext.request.contextPath}/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- AdminLTE App -->
<script src="${pageContext.request.contextPath}/dist/js/adminlte.min.js"></script>

</body>
</html>
