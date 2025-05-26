<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Find ID / Password</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
  <style>
    body {
      background-color: #f5f6fa;
      font-family: 'Segoe UI', sans-serif;
    }
    .tabs-nav {
      display: flex;
      justify-content: center;
      flex-wrap: wrap;
      background-color: #ffffff;
      border-bottom: 1px solid #ddd;
      margin-bottom: 20px;
    }
    .tab-link {
      flex: 1 1 50%;
      text-align: center;
      padding: 15px;
      cursor: pointer;
      font-weight: 500;
      color: #555;
      border-bottom: 3px solid transparent;
      transition: all 0.3s ease-in-out;
    }
    .tab-link.active {
      border-color: #007bff;
      color: #007bff;
      font-weight: bold;
    }
    .container-box {
      width: 90%;
      max-width: 500px;
      margin: 30px auto;
      background: #ffffff;
      padding: 30px 20px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    h4 {
      font-size: 1.4rem;
      font-weight: bold;
      margin-bottom: 25px;
      text-align: center;
    }
    .tab-content {
      display: none;
    }
    .tab-content.active {
      display: block;
    }
    .form-group label {
      font-weight: 500;
      color: #333;
    }
    .btn-block {
      padding: 10px;
      font-weight: bold;
    }
    .form-inline-responsive {
      display: flex;
      flex-direction: column;
    }
    @media (min-width: 576px) {
      .form-inline-responsive {
        flex-direction: row;
        gap: 10px;
        align-items: center;
      }
    }
  </style>
</head>
<body>
  <div class="tabs-nav">
    <div class="tab-link active" data-tab="id">Find ID</div>
    <div class="tab-link" data-tab="pw">Find Password</div>
  </div>

  <div class="container-box">
    <!-- Find ID -->
    <div class="tab-content active" id="tab-id">
      <h4>Verify with your email</h4>
      <form action="findIDAction.jsp" method="post">
        <div class="form-group">
          <label for="name">Name</label>
          <input type="text" class="form-control" id="name" name="name" required>
        </div>
        <div class="form-group">
          <label for="email-id">Email</label>
          <div class="form-inline-responsive">
            <input type="email" class="form-control mb-2 mb-sm-0" id="email-id" name="email" placeholder="Enter your email" required>
            <button type="button" class="btn btn-outline-primary" onclick="sendCode()">Send Code</button>
          </div>
        </div>
        <div class="form-group">
          <label for="verify-code">Verification Code</label>
          <input type="text" class="form-control" id="verify-code" name="code" maxlength="6" placeholder="Enter 6-digit code" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Find ID</button>
      </form>
    </div>

    <!-- Find Password -->
    <div class="tab-content" id="tab-pw">
      <h4>Verify with registered email</h4>
      <form action="findPWAction.jsp" method="post">
        <div class="form-group">
          <label for="userid">User ID</label>
          <input type="text" class="form-control" id="userid" name="userid" required>
        </div>
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" class="form-control" id="email" name="email" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block">Find Password</button>
      </form>
    </div>
  </div>

  <script>
  const tabLinks = document.querySelectorAll('.tab-link');
  const tabContents = document.querySelectorAll('.tab-content');

  tabLinks.forEach(link => {
    link.addEventListener('click', () => {
      tabLinks.forEach(l => l.classList.remove('active'));
      tabContents.forEach(c => c.classList.remove('active'));

      link.classList.add('active');
      document.getElementById('tab-' + link.dataset.tab).classList.add('active');
    });
  });

  function sendCode() {
    const email = document.getElementById('email-id').value;
    if (!email) {
      alert("Please enter your email address first.");
      return;
    }
    alert("Verification code has been sent. If you did not receive it, please check that your information matches your registered details.");
    // This is just a placeholder. Implement actual email sending via backend.
  }
</script>
</body>
</html>