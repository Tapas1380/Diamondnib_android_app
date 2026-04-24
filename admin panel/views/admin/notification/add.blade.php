@extends('admin.layout.page-app')
@section('page_title', __('Label.Add_Notification'))

@section('content')
	@include('admin.layout.sidebar')

	<div class="right-content">
		@include('admin.layout.header')

		<div class="body-content">
			<!-- mobile title -->
			<h1 class="page-title-sm">{{__('Label.Add_Notification')}}</h1>

			<div class="border-bottom row">
				<div class="col-sm-10">
					<ol class="breadcrumb">
						<li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
						<li class="breadcrumb-item"><a href="{{ route('notification.index') }}">{{__('Label.Notification')}}</a></li>
						<li class="breadcrumb-item active" aria-current="page">{{__('Label.Add_Notification')}}</li>
					</ol>
				</div>
				<div class="col-sm-2 d-flex align-items-center justify-content-end">
					<a href="{{ route('notification.index') }}" class="btn btn-default mw-120" style="margin-top:-14px">{{__('Label.Notification_List')}}</a>
				</div>
			</div>

			<div class="card custom-border-card mt-3">
				<form id="notification" enctype="multipart/form-data">
					<input type="hidden" name="id" value="">
					<div class="form-row">
						<div class="col-md-8">
							<div class="form-row">
								<div class="col-md-12">
									<div class="form-group">
										<label>{{__('Label.Title')}}</label>
										<input name="title" type="text" class="form-control" placeholder="Enter Title" autofocus>
									</div>
								</div>
							</div>
							<div class="form-row">
								<div class="col-md-12">
									<div class="form-group">
										<label>{{__('Label.Message')}}</label>
										<textarea class="form-control" rows="5" name="message" placeholder="{{__('Label.Start Write Here...')}}"></textarea>
									</div>
								</div>
							</div>
						</div>
						<div class="col-md-3 ml-5">
							<div class="form-group ">
								<label class="">Image<span class="text-danger">*</span></label>
								<div class="avatar-upload ">
									<div class="avatar-edit">
										<input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg" />
										<label for="imageUpload" title="Select File"></label>
									</div>
									<div class="avatar-preview">
										<img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreview">
									</div>
								</div>
								<label class="mt-3  text-gray">Maximum size 2MB.</label>
							</div>
						</div>
					</div>
					<div class="border-top pt-3 text-right">
						<button type="button" class="btn btn-default mw-120" onclick="save_notification()">{{__('Label.SAVE')}}</button>
						<a href="{{route('notification.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
						<input type="hidden" name="_token" value="{{ csrf_token() }}">
					</div>
				</form>
			</div>
		</div>
	</div>
@endsection

@section('pagescript')
	<script>

        // Sidebar Scroll Down
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

		function save_notification() {

			$("#dvloader").show();
			var formData = new FormData($("#notification")[0]);
			$.ajax({
				type: 'POST',
				url: '{{ route("notification.store") }}',
				data: formData,
				cache: false,
				contentType: false,
				processData: false,
				success: function(resp) {
					$("#dvloader").hide();
					get_responce_message(resp, 'notification', '{{ route("notification.index") }}');
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					$("#dvloader").hide();
					toastr.error(errorThrown, textStatus);
				}
			});
		}
	</script>
@endsection