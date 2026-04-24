@extends('artist.layout.page-app')
@section('page_title',  'Profile')

@section('content')
	@include('artist.layout.sidebar')

	<div class="right-content">
		@include('artist.layout.header')

		<div class="body-content">
			<!-- mobile title -->
			<h1 class="page-title-sm">Profile</h1>

			<div class="border-bottom row mb-3">
				<div class="col-sm-12">
					<ol class="breadcrumb">
						<li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
						<li class="breadcrumb-item active" aria-current="page">Profile</li>
					</ol>
				</div>
			</div>

            <div class="card custom-border-card">
                <form id="profile" enctype="multipart/form-data" autocomplete="off">
                    <input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
                    <h5 class="card-header">Edit Profile</h5>
                    <div class="card-body">
                        <div class="form-row">
                            <div class="col-md-9">
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>User Name<span class="text-danger">*</span></label>
                                            <input type="text" name="user_name" value="@if($data){{$data->user_name}}@endif" class="form-control" placeholder="Enter User Name" autofocus>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Instagram URL<span class="text-danger">*</span></label>
                                            <input type="text" name="instagram_url" value="@if($data){{$data->instagram_url}}@endif" class="form-control" placeholder="Enter URL">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Facebook URL<span class="text-danger">*</span></label>
                                            <input type="text" name="facebook_url" value="@if($data){{$data->facebook_url}}@endif" class="form-control" placeholder="Enter URL">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Bio')}}<span class="text-danger">*</span></label>
                                            <textarea name="bio" rows="1" class="form-control" placeholder="Describe Your Self...">@if($data){{$data->bio}}@endif</textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group ml-5">
                                    <label class="ml-5">Image<span class="text-danger">*</span></label>
                                    <div class="avatar-upload ml-5">
                                        <div class="avatar-edit">
                                            <input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                            <label for="imageUpload" title="Select File"></label>
                                        </div>
                                        <div class="avatar-preview">
                                            <img src="{{$data->image}}" alt="upload_img.png" id="imagePreview">
                                        </div>
                                    </div>
                                    <input type="hidden" name="old_image" value="@if($data){{$data->image}}@endif">
                                    <label class="mt-3 ml-5 text-gray">Maximum size 2MB.</label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="update_profile()">{{__('Label.UPDATE')}}</button>
                        <input type="hidden" name="_method" value="PATCH">
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
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    enctype: 'multipart/form-data',
                    type: 'POST',
                    url: '{{route("aprofile.update", [$data->id])}}',
                    data: formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'profile', '{{ route("aprofile.index") }}');
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