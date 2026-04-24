<!doctype html><html><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Payment Failed</title>
<style>
body{font-family:Arial;background:#1c1010;color:#fff;display:flex;align-items:center;justify-content:center;height:100vh;margin:0}
.card{background:#2a1515;padding:30px;border-radius:12px;text-align:center;max-width:400px}
.x{font-size:50px;margin-bottom:10px}
</style></head><body>
<div class="card">
  <div class="x">❌</div>
  <h2>Payment Failed</h2>
  <p>Txn: {{ $txnid }}<br>Amount: {{ $amount }}</p>
  <a href="myapp://payu/failure?txnid={{ urlencode($txnid) }}" style="color:#f66;">Back to App</a>
</div>
<script>
setTimeout(()=>{window.location.href = "myapp://payu/failure?txnid={{ urlencode($txnid) }}";}, 1500);
</script>
</body></html>