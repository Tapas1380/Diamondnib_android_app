@extends('admin.layout.page-app')
@section('page_title', __('Label.Edit_Payment'))

@section('content')
	@include('admin.layout.sidebar')

	<div class="right-content">
		@include('admin.layout.header')

		<div class="body-content">
			<!-- mobile title -->
			<h1 class="page-title-sm">{{__('Label.Edit_Payment')}}</h1>

			<div class="border-bottom row mb-3">
				<div class="col-sm-10">
					<ol class="breadcrumb">
						<li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
						<li class="breadcrumb-item"><a href="{{ route('payment.index') }}">{{__('Label.Payment')}}</a></li>
						<li class="breadcrumb-item active" aria-current="page">{{__('Label.Edit Payment')}}</li>
					</ol>
				</div>
				<div class="col-sm-2 d-flex align-items-center justify-content-end">
					<a href="{{ route('payment.index') }}" class="btn btn-default mw-120" style="margin-top:-14px">{{__('Label.Payment List')}}</a>
				</div>
			</div>

			<div class="card custom-border-card mt-3">
				<div class="card-body">
					<form name="payment" id="payment_update" enctype="multipart/form-data" autocomplete="off">
						<input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
						<div class="form-row">
							<div class="col-md-4">
								<div class="form-group">
									<label>{{__('Label.NAME')}}</label>
									<input name="name" type="text" class="form-control" readonly value="@if($data){{$data->name}}@endif">
								</div>
							</div>
							<div class="col-md-4">
								<div class="form-group">
									<label>{{__('Label.Status')}}</label>
									<select class="form-control" name="visibility">
										<option value="">{{__('Label.Select Visibility')}}</option>
										<option value="1" {{$data->visibility == 1 ? 'selected' : ''}}>{{__('Label.Active')}}</option>
										<option value="0" {{$data->visibility == 0 ? 'selected' : ''}}>{{__('Label.In Active')}}</option>
									</select>
								</div>
							</div>
							<div class="col-md-4">
								<div class="form-group">
									<label>{{__('Label.Payment Environment')}}</label>
									<select class="form-control" name="is_live">
										<option value="">{{__('Label.Select Payment Environment')}}</option>
										<option value="1" {{$data->is_live == 1 ? 'selected' : ''}}>{{__('Label.Live')}}</option>
										<option value="0" {{$data->is_live == 0 ? 'selected' : ''}}>{{__('Label.Sandbox')}}</option>
									</select>
								</div>
							</div>
						</div>
						<!-- Paypal -->
						@if($data->id == 2)
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>Client ID</label>
										<input name="key_1" type="text" class="form-control" placeholder="Please Enter Client ID" value="{{$data->key_1}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Secret Key</label>
										<input name="key_2" type="text" class="form-control" placeholder="Please Enter Secret Key" value="{{$data->key_2}}">
									</div>
								</div>
							</div>
						@endif
						<!-- Razorpay -->
						@if($data->id == 3)
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>Key</label>
										<input name="key_1" type="text" class="form-control" placeholder="Please Enter Key" value="{{$data->key_1}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Secret Key</label>
										<input name="key_2" type="text" class="form-control" placeholder="Please Enter Secret Key" value="{{$data->key_2}}">
									</div>
								</div>
							</div>
						@endif
						<!-- FlutterWave -->
						@if($data->id == 4)
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>Public ID</label>
										<input name="key_1" type="text" class="form-control" placeholder="Please Enter Public ID" value="{{ $data->key_1}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Encryption Key</label>
										<input name="key_2" type="text" class="form-control" placeholder="Please Enter Encryption Key" value="{{ $data->key_2}}">
									</div>
								</div>
							</div>
						@endif
						<!-- PayUMoney -->
						@if($data->id == 5)
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>Merchant ID</label>
										<input name="key_1" type="text" class="form-control" placeholder="Please Enter Merchant ID" value="{{ $data->key_1}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Merchant Key</label>
										<input name="key_2" type="text" class="form-control" placeholder="Please Enter Merchant Key" value="{{ $data->key_2}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Merchant Salt Key</label>
										<input name="key_3" type="text" class="form-control" placeholder="Please Enter Merchant Salt Key" value="{{ $data->key_3}}">
									</div>
								</div>
							</div>
						@endif
						<!-- PayTm -->
						@if($data->id == 6)
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>Merchant ID</label>
										<input name="key_1" type="text" class="form-control" placeholder="Please Enter Merchant ID" value="{{ $data->key_1}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Merchant Key</label>
										<input name="key_2" type="text" class="form-control" placeholder="Please Enter Merchant Key" value="{{ $data->key_2}}">
									</div>
								</div>
							</div>
						@endif
						<!-- Stripe -->
						@if($data->id == 7)
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>Publishable key</label>
										<input name="key_1" type="text" class="form-control" placeholder="Please Enter Publishable key" value="{{$data->key_1}}">
									</div>
								</div>
								<div class="col-md-4">
									<div class="form-group">
										<label>Secret Key</label>
										<input name="key_2" type="text" class="form-control" placeholder="Please Enter Secret Key" value="{{$data->key_2}}">
									</div>
								</div>
							</div>
						@endif
						<div class="border-top pt-3 text-right">
							<button type="button" class="btn btn-default mw-120" onclick="update_payment()">{{__('Label.UPDATE')}}</button>
							<a href="{{route('payment.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
							<input type="hidden" name="_method" value="PATCH">
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
@endsection

@section('pagescript')
	<script>

        // Sidebar Scroll Down
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

		function update_payment() {
			$("#dvloader").show();
			var formData = new FormData($("#payment_update")[0]);

			$.ajax({
				headers: {
					'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
				},
				enctype: 'multipart/form-data',
				type: 'POST',
				url: '{{route("payment.update", [$data->id])}}',
				data: formData,
				cache: false,
				contentType: false,
				processData: false,
				success: function(resp) {
					$("#dvloader").hide();
					get_responce_message(resp, 'payment_update', '{{ route("payment.index") }}');
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					$("#dvloader").hide();
					toastr.error(errorThrown, textStatus);
				}
			});
		}
	</script>
@endsection