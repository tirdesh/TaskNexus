<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>TaskNexus | Dashboard</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <link rel="shortcut icon" type="image/png" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/dist/img/Logo.png">
  <!-- CSRF Token -->
  <meta name="_csrf" content="${_csrf.token}"/>
  <meta name="_csrf_header" content="${_csrf.headerName}"/>
  <!-- Font Awesome -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/fontawesome-free/css/all.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css">
  <!-- Tempusdominus Bbootstrap 4 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
  <!-- iCheck -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
  <!-- JQVMap -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/jqvmap/jqvmap.min.css">
  <!-- Theme style - AdminLTE 3.2.0 (CDN) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css">
  <!-- overlayScrollbars -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
  <!-- Daterange picker -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/daterangepicker/daterangepicker.css">
  <!-- summernote -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/summernote/summernote-bs4.css">
  <!-- Google Font: Source Sans Pro -->
  <link href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300;400;600;700&display=swap" rel="stylesheet">
  <!-- SweetAlert2 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/plugins/sweetalert2/sweetalert2.min.css">
  <!-- CSRF Token meta tags (duplicate for compatibility - used by JavaScript) -->
  <meta name="_csrf" content="${_csrf.token}"/>
  <meta name="_csrf_header" content="${_csrf.headerName}"/>
  <style>
    /* Modern AdminLTE Design Enhancements */
    
    /* Brand logo/text behavior - Modern Design */
    .main-sidebar .brand-link {
      display: flex;
      align-items: center;
      padding: 1.25rem 1rem;
      overflow: hidden;
      border-bottom: 2px solid rgba(255,255,255,.1);
      justify-content: flex-start;
      background: linear-gradient(135deg, rgba(0,123,255,.1) 0%, transparent 100%);
      transition: all 0.3s ease;
    }
    .main-sidebar .brand-link:hover {
      background: linear-gradient(135deg, rgba(0,123,255,.15) 0%, transparent 100%);
    }
    .main-sidebar .brand-link .logo-xs {
      display: none;
      margin: 0 auto;
    }
    .main-sidebar .brand-link .logo-xs img {
      height: 40px;
      width: auto;
      border-radius: 8px;
      display: block;
      margin: 0 auto;
      box-shadow: 0 2px 8px rgba(0,0,0,.2);
      border: 2px solid rgba(255,255,255,.1);
      transition: all 0.3s ease;
    }
    .main-sidebar .brand-link .logo-xl {
      line-height: 36px;
      white-space: nowrap;
      font-size: 1.5rem;
      font-weight: 700;
      padding-left: 0;
      margin-left: 0;
      color: #ffffff;
      text-shadow: 0 2px 4px rgba(0,0,0,.2);
      /* Align with nav item text (icon width 1.75rem + margin 0.875rem = 2.625rem) */
      padding-left: 2.625rem;
      letter-spacing: 0.5px;
      transition: all 0.3s ease;
      opacity: 1;
      visibility: visible;
    }
    .main-sidebar .brand-link .logo-xl b {
      color: #007bff;
      text-shadow: 0 0 10px rgba(0,123,255,.5);
    }
    /* collapsed: show only logo-xs; expanded: show only logo-xl */
    .main-sidebar .brand-link .logo-xs { display: none; }
    .main-sidebar .brand-link .logo-xl { display: inline-block; }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link {
      justify-content: center;
      padding: 1.25rem 0.5rem;
      background: transparent;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link:hover {
      background: rgba(0,123,255,.1);
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link .logo-xl { display: none !important; }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link .logo-xs { 
      display: flex !important;
      align-items: center;
      justify-content: center;
    }
    /* When sidebar expands on hover in collapsed mode */
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .brand-link,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .brand-link {
      justify-content: flex-start;
      padding: 1.25rem 1rem;
      align-items: center;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .brand-link .logo-xs,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .brand-link .logo-xs {
      display: none !important;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .brand-link .logo-xl,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .brand-link .logo-xl {
      display: inline-block !important;
      opacity: 1 !important;
      visibility: visible !important;
      padding-left: 2.625rem;
      margin-left: 0;
      animation: fadeIn 0.3s ease;
    }
    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateX(-10px);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }
    .sidebar-mini:not(.sidebar-collapse) .main-sidebar .brand-link .logo-xs { display: none !important; }
    .sidebar-mini:not(.sidebar-collapse) .main-sidebar .brand-link .logo-xl { display: inline-block !important; }
    
    /* Modern Navbar Styling */
    .main-header .navbar {
      background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
      box-shadow: 0 2px 8px rgba(0,0,0,.1);
      padding: 0.75rem 1.5rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-bottom: 2px solid #e9ecef;
    }
    .main-header .navbar-nav {
      display: flex;
      align-items: center;
      flex-direction: row;
    }
    .main-header .navbar-nav .nav-item {
      display: flex;
      align-items: center;
    }
    .main-header .navbar-nav .nav-link {
      border-radius: 0.5rem;
      margin: 0 0.25rem;
      padding: 0.625rem 1rem;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 2.75rem;
      color: #495057;
      font-weight: 500;
    }
    .main-header .navbar-nav .nav-link i {
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.1rem;
    }
    .main-header .navbar-nav .nav-link:hover {
      background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
      transform: translateY(-1px);
      box-shadow: 0 2px 4px rgba(0,0,0,.1);
    }
    .main-header .navbar-nav .nav-link .user-panel {
      display: flex;
      align-items: center;
    }
    .main-header .navbar-nav .nav-link .user-panel .info {
      text-align: left;
    }
    .main-header .navbar-nav .dropdown-menu {
      border: none;
      box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,.2);
      border-radius: 0.75rem;
      margin-top: 0.75rem;
      padding: 0;
      overflow: hidden;
      min-width: 280px;
    }
    /* User Dropdown Styling */
    .main-header .navbar-nav .dropdown-menu {
      border-radius: 0.5rem;
      border: 1px solid rgba(0,0,0,.1);
      min-width: 260px;
    }
    .main-header .navbar-nav .dropdown-menu .dropdown-header {
      padding: 1rem 1.25rem;
      background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
      border: none;
    }
    .user-avatar-dropdown {
      width: 48px;
      height: 48px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    .user-avatar-dropdown i {
      font-size: 2.5rem;
      color: #ffffff;
    }
    .user-info-dropdown {
      flex: 1;
      min-width: 0;
    }
    .user-email-dropdown {
      font-size: 0.9375rem;
      color: #ffffff;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      line-height: 1.4;
    }
    .user-welcome-dropdown {
      font-size: 0.8125rem;
      color: rgba(255, 255, 255, 0.85);
      margin-top: 0.125rem;
    }
    .main-header .navbar-nav .dropdown-menu .dropdown-item {
      padding: 0.75rem 1.25rem;
      transition: all 0.2s ease;
      border-left: 3px solid transparent;
      display: flex;
      align-items: center;
    }
    .main-header .navbar-nav .dropdown-menu .dropdown-item:hover {
      background-color: #f8f9fa;
      border-left-color: #007bff;
      padding-left: 1.5rem;
    }
    .main-header .navbar-nav .dropdown-menu .dropdown-item i {
      width: 1.5rem;
      text-align: center;
      flex-shrink: 0;
    }
    /* User Panel in Navbar Alignment */
    .main-header .navbar-nav .user-panel {
      min-width: 0;
    }
    .main-header .navbar-nav .user-panel .image {
      flex-shrink: 0;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .main-header .navbar-nav .user-panel .info {
      min-width: 0;
      flex: 1;
    }
    .main-header .navbar-nav .user-panel .info span {
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      display: block;
    }
    .main-header .navbar-nav .dropdown-menu .dropdown-item:not(.dropdown-header) {
      color: #495057;
    }
    .main-header .navbar-nav .dropdown-menu .dropdown-divider {
      margin: 0.25rem 0;
    }
    
    /* Ensure hamburger menu is properly aligned */
    .main-header .navbar-nav:first-child {
      margin-right: auto;
    }
    .main-header .navbar-nav.ml-auto {
      margin-left: auto;
    }
    
    /* Modern Sidebar Styling */
    .main-sidebar {
      background: linear-gradient(180deg, #343a40 0%, #2c3136 100%);
      box-shadow: 4px 0 12px rgba(0,0,0,.15);
      border-right: 1px solid rgba(255,255,255,.05);
    }
    .sidebar {
      padding: 0.5rem 0;
    }
    .nav-sidebar {
      padding: 0.5rem 0;
      overflow: visible;
    }
    /* Ensure text doesn't get cut off when sidebar expands */
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar {
      overflow: visible;
      white-space: nowrap;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar .nav-link,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar .nav-link {
      white-space: nowrap;
      overflow: visible;
    }
    .nav-sidebar > .nav-item {
      margin: 0.25rem 0.5rem;
    }
    .nav-sidebar > .nav-item > .nav-link {
      margin: 0;
      padding: 0.875rem 1rem;
      border-radius: 0.75rem;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      display: flex;
      align-items: center;
      justify-content: flex-start;
      color: rgba(255,255,255,.8);
      position: relative;
      overflow: hidden;
    }
    .nav-sidebar > .nav-item > .nav-link::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
      width: 4px;
      background: linear-gradient(180deg, #007bff 0%, #0056b3 100%);
      transform: scaleY(0);
      transition: transform 0.3s ease;
    }
    .nav-sidebar > .nav-item > .nav-link:hover {
      background: linear-gradient(90deg, rgba(0,123,255,.15) 0%, rgba(0,123,255,.05) 100%);
      color: #ffffff;
      transform: translateX(6px);
      box-shadow: 0 2px 8px rgba(0,0,0,.1);
    }
    .nav-sidebar > .nav-item > .nav-link:hover::before {
      transform: scaleY(1);
    }
    .nav-sidebar > .nav-item > .nav-link.active {
      background: linear-gradient(90deg, rgba(0,123,255,.2) 0%, rgba(0,123,255,.1) 100%);
      color: #ffffff;
      font-weight: 600;
      box-shadow: 0 2px 8px rgba(0,123,255,.2);
    }
    .nav-sidebar > .nav-item > .nav-link.active::before {
      transform: scaleY(1);
    }
    .nav-sidebar .nav-icon {
      width: 1.75rem;
      text-align: center;
      margin-right: 0.875rem;
      flex-shrink: 0;
      font-size: 1.1rem;
      transition: all 0.3s ease;
    }
    .nav-sidebar > .nav-item > .nav-link:hover .nav-icon {
      transform: scale(1.1);
      color: #007bff;
    }
    .nav-sidebar > .nav-item > .nav-link.active .nav-icon {
      color: #007bff;
    }
    .nav-sidebar .nav-link p {
      margin: 0;
      padding: 0;
      font-size: 0.95rem;
      font-weight: 500;
      letter-spacing: 0.3px;
    }
    /* Collapsed sidebar alignment - Enhanced */
    .sidebar-mini.sidebar-collapse .nav-sidebar {
      padding: 0.5rem 0;
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item {
      margin: 0.375rem 0;
      padding: 0;
      width: 100%;
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link {
      justify-content: center;
      margin: 0 auto;
      padding: 1rem;
      border-radius: 0.75rem;
      position: relative;
      width: calc(100% - 1rem);
      max-width: 50px;
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link::after {
      content: attr(data-title);
      position: absolute;
      left: calc(100% + 0.75rem);
      top: 50%;
      transform: translateY(-50%);
      background: linear-gradient(135deg, #343a40 0%, #2c3136 100%);
      color: #ffffff;
      padding: 0.5rem 0.75rem;
      border-radius: 0.5rem;
      white-space: nowrap;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
      pointer-events: none;
      font-size: 0.875rem;
      font-weight: 500;
      box-shadow: 0 4px 12px rgba(0,0,0,.3);
      z-index: 1000;
      border: 1px solid rgba(255,255,255,.1);
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link::before {
      content: '';
      position: absolute;
      left: calc(100% + 0.5rem);
      top: 50%;
      transform: translateY(-50%);
      border: 6px solid transparent;
      border-right-color: #343a40;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
      z-index: 1001;
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link:hover::after,
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link:hover::before {
      opacity: 1;
      visibility: visible;
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link:hover {
      transform: scale(1.1);
      background: linear-gradient(135deg, rgba(0,123,255,.25) 0%, rgba(0,123,255,.15) 100%);
      box-shadow: 0 4px 12px rgba(0,123,255,.3);
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar > .nav-item > .nav-link.active {
      background: linear-gradient(135deg, rgba(0,123,255,.3) 0%, rgba(0,123,255,.2) 100%);
      box-shadow: 0 4px 12px rgba(0,123,255,.4);
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar .nav-icon {
      margin-right: 0;
      width: auto;
      font-size: 1.25rem;
    }
    .sidebar-mini.sidebar-collapse .nav-sidebar .nav-link p {
      display: none;
    }
    /* When sidebar expands on hover - show full text */
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar > .nav-item > .nav-link,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar > .nav-item > .nav-link {
      justify-content: flex-start;
      margin: 0.25rem 0.75rem;
      padding: 0.875rem 1rem;
      width: auto;
      max-width: none;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar .nav-link p,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar .nav-link p {
      display: block !important;
      opacity: 1 !important;
      visibility: visible !important;
      width: auto !important;
      margin-left: 0 !important;
      animation: fadeIn 0.3s ease;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar .nav-icon,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar .nav-icon {
      margin-right: 0.875rem;
      width: 1.75rem;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar > .nav-item > .nav-link::after,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar > .nav-item > .nav-link::after {
      display: none;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar:hover .nav-sidebar > .nav-item > .nav-link::before,
    .sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .nav-sidebar > .nav-item > .nav-link::before {
      display: none;
    }
    /* Enhanced collapsed brand logo */
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link {
      border-bottom: 2px solid rgba(255,255,255,.1);
      padding: 1.5rem 0.5rem;
      position: relative;
      justify-content: center;
      align-items: center;
      overflow: visible;
      margin: 0;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link .logo-xs {
      display: flex !important;
      align-items: center;
      justify-content: center;
      width: 100%;
      margin: 0;
      padding: 0;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link .logo-xs img {
      height: 44px;
      width: 44px;
      object-fit: contain;
      border: 2px solid rgba(0,123,255,.3);
      box-shadow: 0 4px 12px rgba(0,123,255,.2);
      transition: all 0.3s ease;
      display: block;
      margin: 0 auto;
    }
    /* Tooltip for brand link in collapsed view - Fixed */
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link::after {
      content: 'TaskNexus';
      position: absolute;
      left: calc(100% + 0.75rem);
      top: 50%;
      transform: translateY(-50%) translateX(-10px);
      background: linear-gradient(135deg, #343a40 0%, #2c3136 100%);
      color: #ffffff;
      padding: 0.625rem 1rem;
      border-radius: 0.5rem;
      white-space: nowrap;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      pointer-events: none;
      font-size: 0.9375rem;
      font-weight: 600;
      box-shadow: 0 4px 12px rgba(0,0,0,.3);
      z-index: 1000;
      border: 1px solid rgba(255,255,255,.1);
      letter-spacing: 0.5px;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link::before {
      content: '';
      position: absolute;
      left: calc(100% + 0.5rem);
      top: 50%;
      transform: translateY(-50%) translateX(-10px);
      border: 6px solid transparent;
      border-right-color: #343a40;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 1001;
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link:hover::after {
      opacity: 1;
      visibility: visible;
      transform: translateY(-50%) translateX(0);
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link:hover::before {
      opacity: 1;
      visibility: visible;
      transform: translateY(-50%) translateX(0);
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link:hover {
      background: rgba(0,123,255,.1);
    }
    .sidebar-mini.sidebar-collapse .main-sidebar .brand-link:hover .logo-xs img {
      transform: scale(1.15);
      box-shadow: 0 6px 16px rgba(0,123,255,.5);
      border-color: rgba(0,123,255,.6);
    }
    /* Sidebar divider/separator */
    .nav-sidebar .nav-header {
      color: rgba(255,255,255,.5);
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 1px;
      padding: 1rem 1rem 0.5rem;
      font-weight: 600;
    }
    
    /* Modern Card Styling */
    .card {
      border: none;
      box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,.075);
      border-radius: 0.5rem;
      transition: all 0.3s ease;
    }
    .card:hover {
      box-shadow: 0 0.5rem 1rem rgba(0,0,0,.15);
      transform: translateY(-2px);
    }
    .card-header {
      border-bottom: 1px solid rgba(0,0,0,.125);
      border-radius: 0.5rem 0.5rem 0 0 !important;
      font-weight: 600;
    }
    
    /* Modern Small Box (Dashboard Cards) */
    .small-box {
      border-radius: 0.75rem;
      box-shadow: 0 0.125rem 0.5rem rgba(0,0,0,.1);
      transition: all 0.3s ease;
      overflow: hidden;
    }
    .small-box:hover {
      transform: translateY(-4px);
      box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,.2);
    }
    .small-box .inner {
      padding: 1.5rem;
    }
    .small-box .icon {
      font-size: 4rem;
      opacity: 0.3;
      transition: all 0.3s ease;
    }
    .small-box:hover .icon {
      opacity: 0.4;
      transform: scale(1.1);
    }
    .small-box-footer {
      border-radius: 0 0 0.75rem 0.75rem;
      padding: 0.75rem;
      font-weight: 600;
      transition: all 0.2s ease;
    }
    .small-box-footer:hover {
      background-color: rgba(0,0,0,.1) !important;
    }
    
    /* Modern Info Box (Dashboard Cards) */
    .info-box {
      display: block;
      min-height: 90px;
      background: #fff;
      width: 100%;
      box-shadow: 0 2px 8px rgba(0,0,0,.1);
      border-radius: 0.75rem;
      margin-bottom: 15px;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      border: 1px solid rgba(0,0,0,.05);
    }
    .info-box:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 24px rgba(0,0,0,.15);
    }
    .info-box-icon {
      border-top-left-radius: 0.75rem;
      border-top-right-radius: 0;
      border-bottom-right-radius: 0;
      border-bottom-left-radius: 0.75rem;
      display: block;
      float: left;
      height: 90px;
      width: 90px;
      text-align: center;
      font-size: 45px;
      line-height: 90px;
      background: rgba(0,0,0,.2);
      transition: all 0.3s ease;
    }
    .info-box:hover .info-box-icon {
      transform: scale(1.05);
    }
    .info-box-content {
      padding: 15px 20px;
      margin-left: 90px;
    }
    .info-box-text {
      text-transform: uppercase;
      font-weight: 600;
      font-size: 0.875rem;
      color: #6c757d;
      display: block;
      letter-spacing: 0.5px;
    }
    .info-box-number {
      display: block;
      font-weight: 700;
      font-size: 2rem;
      color: #343a40;
      margin: 5px 0;
    }
    .info-box .count-number {
      font-size: 2.5rem;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      font-weight: 800;
    }
    .info-box .progress {
      background: #f4f4f4;
      margin: 5px -10px 5px -10px;
      height: 3px;
      border-radius: 2px;
    }
    .info-box .progress-description {
      margin-top: 8px;
      font-size: 0.875rem;
    }
    .info-box .progress-description a {
      text-decoration: none;
      font-weight: 500;
      transition: all 0.2s ease;
    }
    .info-box .progress-description a:hover {
      text-decoration: underline;
      transform: translateX(3px);
    }
    
    /* Quick Actions Buttons */
    .btn-lg {
      padding: 1rem 1.5rem;
      font-size: 1rem;
      font-weight: 600;
      border-radius: 0.5rem;
      transition: all 0.3s ease;
    }
    .btn-lg:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,.2);
    }
    .btn-lg i {
      font-size: 1.1rem;
    }
    
    /* Modern Button Styling */
    .btn {
      border-radius: 0.375rem;
      font-weight: 500;
      padding: 0.5rem 1rem;
      transition: all 0.2s ease;
    }
    .btn:hover {
      transform: translateY(-1px);
      box-shadow: 0 0.25rem 0.5rem rgba(0,0,0,.2);
    }
    .btn-sm {
      padding: 0.25rem 0.75rem;
      font-size: 0.875rem;
    }
    
    /* Modern Form Styling */
    .form-control, .form-select {
      border-radius: 0.375rem;
      border: 1px solid #dee2e6;
      transition: all 0.2s ease;
    }
    .form-control:focus, .form-select:focus {
      border-color: #80bdff;
      box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25);
    }
    
    /* Modern Table Styling */
    .table {
      border-radius: 0.5rem;
      overflow: hidden;
    }
    .table thead {
      background-color: #f8f9fa;
    }
    .table tbody tr {
      transition: all 0.2s ease;
    }
    .table tbody tr:hover {
      background-color: #f8f9fa;
      transform: scale(1.01);
    }
    
    /* Modern Badge Styling */
    .badge {
      padding: 0.35em 0.65em;
      border-radius: 0.375rem;
      font-weight: 600;
    }
    
    /* Content Header Modern Styling */
    .content-header {
      padding: 1.5rem 0;
    }
    .content-header h1 {
      font-weight: 700;
      font-size: 2rem;
    }
    
    /* Modern Content Section */
    .content {
      padding: 1.5rem 0;
    }
    
    /* Smooth Transitions */
    * {
      transition: background-color 0.2s ease, color 0.2s ease;
    }
    
    /* Modern Scrollbar */
    ::-webkit-scrollbar {
      width: 8px;
      height: 8px;
    }
    ::-webkit-scrollbar-track {
      background: #f1f1f1;
    }
    ::-webkit-scrollbar-thumb {
      background: #888;
      border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: #555;
    }
    
    /* Modern Footer Styling */
    .main-footer {
      background: linear-gradient(135deg, #343a40 0%, #212529 100%);
      color: #ffffff;
      padding: 1.5rem 1.5rem;
      border-top: 3px solid #007bff;
      box-shadow: 0 -2px 8px rgba(0,0,0,.1);
    }
    .main-footer a {
      color: #ffffff;
      text-decoration: none;
      transition: all 0.2s ease;
    }
    .main-footer a:hover {
      color: #007bff;
      text-decoration: underline;
    }
    .main-footer .text-muted {
      color: rgba(255,255,255,.7) !important;
    }
    .main-footer .text-danger {
      color: #ff6b6b !important;
    }
    
    /* Action Buttons Styling */
    .action-btn {
      width: 36px;
      height: 36px;
      padding: 0;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 0.375rem;
      transition: all 0.3s ease;
      margin-right: 4px;
      box-shadow: 0 2px 4px rgba(0,0,0,.1);
    }
    .action-btn:last-child {
      margin-right: 0;
    }
    .action-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0,0,0,.2);
    }
    .action-btn i {
      font-size: 0.875rem;
    }
    .btn-group .action-btn {
      margin-right: 0;
      border-radius: 0;
    }
    .btn-group .action-btn:first-child {
      border-top-left-radius: 0.375rem;
      border-bottom-left-radius: 0.375rem;
    }
    .btn-group .action-btn:last-child {
      border-top-right-radius: 0.375rem;
      border-bottom-right-radius: 0.375rem;
    }
    .btn-group .action-btn:not(:first-child):not(:last-child) {
      border-radius: 0;
    }
    
    /* Project Details Page Styling */
    .badge-lg {
      padding: 0.5rem 0.75rem;
      font-size: 0.875rem;
      font-weight: 600;
    }
    .progress-info {
      background: #f8f9fa;
      padding: 1rem;
      border-radius: 0.5rem;
      border: 1px solid #dee2e6;
    }
    .progress-info .progress {
      border-radius: 0.5rem;
      overflow: hidden;
    }
    .progress-info .progress-bar {
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-weight: 600;
    }
    .list-group-item {
      border-left: 3px solid transparent;
      transition: all 0.2s ease;
    }
    .list-group-item:hover {
      border-left-color: #007bff;
      background-color: #f8f9fa;
    }
    .list-group-item .fa-user-circle {
      width: 2rem;
      height: 2rem;
    }
    dl.row dt {
      font-weight: 600;
      color: #495057;
      padding-top: 0.5rem;
    }
    dl.row dd {
      padding-top: 0.5rem;
    }
    .table-hover tbody tr:hover {
      background-color: #f8f9fa;
    }
    .table thead th {
      border-bottom: 2px solid #dee2e6;
      font-weight: 600;
      text-transform: uppercase;
      font-size: 0.75rem;
      letter-spacing: 0.5px;
    }
    
    /* Task/Project Form Styling */
    .form-group label {
      font-weight: 600;
      color: #495057;
      margin-bottom: 0.5rem;
    }
    .form-group label i {
      width: 1.25rem;
      text-align: center;
    }
    .form-control:focus {
      border-color: #007bff;
      box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
    }
    .card-footer {
      background-color: #f8f9fa;
      border-top: 1px solid #dee2e6;
    }
  </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">

  <!-- Navbar -->
  <nav class="main-header navbar navbar-expand navbar-white navbar-light">
    <!-- Left navbar links -->
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" data-widget="pushmenu" href="#" role="button" aria-label="Toggle sidebar">
          <i class="fas fa-bars"></i>
        </a>
      </li>
      <li class="nav-item d-none d-sm-inline">
        <a href="${pageContext.request.contextPath}/page" class="nav-link">
          <i class="fas fa-home"></i>
        </a>
      </li>
    </ul>

    <!-- Right navbar links -->
    <ul class="navbar-nav ml-auto">
      <!-- User Dropdown Menu -->
      <li class="nav-item dropdown">
        <a class="nav-link" data-toggle="dropdown" href="#" role="button" aria-expanded="false">
          <div class="d-flex align-items-center">
            <div class="user-panel d-flex align-items-center">
              <div class="image">
                <i class="fas fa-user-circle fa-2x text-primary"></i>
              </div>
              <div class="info d-none d-md-block ml-2">
                <span class="d-block text-sm font-weight-bold"><sec:authentication property="principal.username" /></span>
                <span class="d-block text-xs text-muted">User Account</span>
              </div>
            </div>
            <i class="fas fa-chevron-down ml-2 d-none d-md-inline text-muted"></i>
          </div>
        </a>
        <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right shadow-lg">
          <div class="dropdown-header bg-primary text-white">
            <div class="d-flex align-items-center">
              <div class="user-avatar-dropdown">
                <i class="fas fa-user-circle"></i>
              </div>
              <div class="user-info-dropdown ml-3">
                <div class="user-email-dropdown font-weight-bold"><sec:authentication property="principal.username" /></div>
                <div class="user-welcome-dropdown">Welcome back!</div>
              </div>
            </div>
          </div>
          <div class="dropdown-divider"></div>
          <a href="${pageContext.request.contextPath}/page" class="dropdown-item">
            <i class="fas fa-tachometer-alt mr-2 text-primary"></i> Dashboard
          </a>
          <a href="${pageContext.request.contextPath}/myTasks" class="dropdown-item">
            <i class="fas fa-tasks mr-2 text-info"></i> My Tasks
          </a>
          <div class="dropdown-divider"></div>
          <a href="javascript:document.getElementById('logoutForm').submit()" class="dropdown-item">
            <i class="fas fa-sign-out-alt mr-2 text-danger"></i> Logout
          </a>
          <form id="logoutForm" action="${pageContext.request.contextPath}/logout" method="post" style="display: none;">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
          </form>
        </div>
      </li>
    </ul>
  </nav>
  <!-- /.navbar -->

  <!-- Main Sidebar Container -->
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
        <a href="${pageContext.request.contextPath}/page" class="brand-link logo-switch" id="nav-dashboard-brand">
      <span class="logo-xs">
        <img src="${pageContext.request.contextPath}/dist/img/Logo.png" alt="TaskNexus Logo" class="brand-image-xs" style="opacity: .9">
      </span>
      <span class="logo-xl brand-text font-weight-light"><b>Task</b>Nexus</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
      <!-- Sidebar Menu -->
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
          <!-- Navigation Links -->
              <li class="nav-item">
            <a href="${pageContext.request.contextPath}/page" class="nav-link" id="nav-dashboard" data-title="Dashboard">
                  <i class="nav-icon fas fa-tachometer-alt"></i>
                  <p>Dashboard</p>
                </a>
              </li>
              <li class="nav-item">
            <a href="${pageContext.request.contextPath}/viewProject" class="nav-link" id="nav-projects" data-title="Projects">
              <i class="nav-icon fas fa-project-diagram"></i>
                  <p>Projects</p>
                </a>
              </li>
              <li class="nav-item">
            <a href="${pageContext.request.contextPath}/viewTask" class="nav-link" id="nav-tasks" data-title="Tasks">
              <i class="nav-icon fas fa-tasks"></i>
                  <p>Tasks</p>
                </a>
              </li>
              <sec:authorize access="hasAuthority('ROLE_ADMIN')">
              <li class="nav-item">
            <a href="${pageContext.request.contextPath}/viewUser" class="nav-link" id="nav-users" data-title="Users">
              <i class="nav-icon fas fa-users"></i>
                  <p>Users</p>
                </a>
              </li>
              </sec:authorize>
        </ul>
      </nav>
      <!-- /.sidebar-menu -->
    </div>
    <!-- /.sidebar -->
  </aside>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">