<!doctype html><html><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Payment Success</title>
<style>
body{font-family:Arial;background:#0e1320;color:#fff;display:flex;align-items:center;justify-content:center;height:100vh;margin:0}
.card{background:#151a2b;padding:30px;border-radius:12px;text-align:center;max-width:400px}
.ok{font-size:50px;margin-bottom:10px}
</style></head><body>
<div class="card">
  <div class="ok">✅</div>
  <h2>Payment Successful</h2>
  <p>Txn: {{ $txnid }}<br>Amount: {{ $amount }}</p>
  <a href="myapp://payu/success?txnid={{ urlencode($txnid) }}" style="color:#0f0;">Back to App</a>
</div>
<script>
setTimeout(()=>{window.location.href = "myapp://payu/success?txnid={{ urlencode($txnid) }}";}, 1500);
</script>
</body></html>