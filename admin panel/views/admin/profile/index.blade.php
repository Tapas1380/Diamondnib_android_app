@extends('admin.layout.page-app')
@section('page_title',  'Profile')

@section('content')
	@include('admin.layout.sidebar')

	<div class="right-content">
		@include('admin.layout.header')

		<div class="body-content">
			<!-- mobile title -->
			<h1 class="page-title-sm">Profile</h1>

			<div class="border-bottom row mb-3">
				<div class="col-sm-12">
					<ol class="breadcrumb">
						<li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
						<li class="breadcrumb-item active" aria-current="page">Profile</li>
					</ol>
				</div>
			</div>

            <!-- Profile Info -->
            <div class="card custom-border-card">
                <form id="profile" enctype="multipart/form-data" autocomplete="off">
                    <input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
                    <h5 class="card-header">Personal Info</h5>
                    <div class="card-body">
                        <div class="form-row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>User Name<span class="text-danger">*</span></label>
                                    <input type="text" name="user_name" value="@if($data){{$data->user_name}}@endif" class="form-control" placeholder="Enter User Name" autofocus>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Email<span class="text-danger">*</span></label>
                                    <input type="text" name="email" value="@if($data){{$data->email}}@endif" class="form-control" placeholder="Enter Email">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="update_profile()">{{__('Label.UPDATE')}}</button>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>

            <!-- Change Password  -->
            <div class="card custom-border-card">
                <form id="change_password" enctype="multipart/form-data" autocomplete="off">
                    <input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
                    <h5 class="card-header">{{__('Label.Change Password')}}</h5>
                    <div class="card-body">
                        <div class="form-row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Current Password<span class="text-danger">*</span></label>
                                    <input type="password" name="current_password" class="form-control" placeholder="Enter Current Password">
                                </div>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.New Password')}}<span class="text-danger">*</span></label>
                                    <input type="password" name="new_password" class="form-control" placeholder="Enter New Password">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Confirm Password')}}<span class="text-danger">*</span></label>
                                    <input type="password" name="confirm_password" class="form-control" placeholder="Enter Confirm Password">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="update_password()">{{__('Label.UPDATE')}}</button>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>
		</div>
	</div>
@endsection

@section('pagescript')
	<script>
		function update_profile(){
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#profile")[0]);

                $.ajax({
                    type: 'POST',
                    url: '{{route("profile.store")}}',
                    data: formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'profile', '{{ route("profile.index") }}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
		}
        function update_password() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#change_password")[0]);

                $.ajax({
                    type: 'POST',
                    url: '{{ route("profile.changepassword") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'change_password', '{{ route("profile.index") }}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        }
	</script>
@endsection