@extends('admin.layout.page-app')
@section('page_title', __('Label.Edit_Package'))

@section('content')
	@include('admin.layout.sidebar')

	<div class="right-content">
		@include('admin.layout.header')

		<div class="body-content">
			<!-- mobile title -->
			<h1 class="page-title-sm">{{__('Label.Edit_Package')}}</h1>

			<div class="border-bottom row mb-3">
				<div class="col-sm-10">
					<ol class="breadcrumb">
						<li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
						<li class="breadcrumb-item"><a href="{{ route('package.index') }}">{{__('Label.Package')}}</a></li>
						<li class="breadcrumb-item active" aria-current="page">{{__('Label.Edit Package')}}</li>
					</ol>
				</div>
				<div class="col-sm-2 d-flex align-items-center justify-content-end">
					<a href="{{ route('package.index') }}" class="btn btn-default mw-120" style="margin-top:-14px">{{__('Label.Package List')}}</a>
				</div>
			</div>

			<div class="card custom-border-card">
				<form id="package_update" enctype="multipart/form-data">
					<input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
					<div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('Label.NAME')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="name" value="@if($data){{$data->name}}@endif" class="form-control" placeholder="{{__('Label.Please Enter Name')}}" autofocus>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label>{{__('Label.Price')}}<span class="text-danger">*</span></label>
                                        <input type="number" value="@if($data){{$data->price}}@endif" name="price" min="0" class="form-control" placeholder="Enter Price">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label>{{__('Label.Coin')}}<span class="text-danger">*</span></label>
                                        <input type="number" value="@if($data){{$data->coin}}@endif" name="coin" min="0" class="form-control" placeholder="Enter Coin">
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Android Product Package</label>
                                        <input name="android_product_package" value="@if($data){{$data->android_product_package}}@endif" type="text" class="form-control" placeholder="Enter Android Product Package">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>IOS Product Package</label>
                                        <input name="ios_product_package" value="@if($data){{$data->ios_product_package}}@endif" type="text" class="form-control" placeholder="Enter IOS Product Package">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
							<div class="form-group ml-5">
								<label class="ml-5">{{__('Label.Image')}}<span class="text-danger">*</span></label>
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
					<div class="border-top pt-3 text-right">
						<button type="button" class="btn btn-default mw-120" onclick="update_package()">{{__('Label.UPDATE')}}</button>
						<a href="{{route('package.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
						<input type="hidden" name="_method" value="PATCH">
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

		function update_package() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#package_update")[0]);
                $.ajax({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    enctype: 'multipart/form-data',
                    type: 'POST',
                    url: '{{route("package.update", [$data->id])}}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'package_update', '{{ route("package.index") }}');
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