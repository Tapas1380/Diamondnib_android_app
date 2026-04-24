@extends('artist.layout.page-app')
@section('page_title', 'Add Music')

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Add Music</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('amusic.index') }}">Music</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Add Music</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('amusic.index') }}" class="btn btn-default mw-120" style="margin-top:-14px">Music List</a>
                </div>
            </div>

            <div class="card custom-border-card mt-3">
                <form id="music" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="">
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="title" class="form-control" placeholder="Enter Title" autofocus>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-8">
                                    <div class="form-group">
                                        <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                        <textarea name="description" class="form-control" rows="4" placeholder="Describe Here,"></textarea>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Category<span class="text-danger">*</span></label>
                                        <select name="category_id" class="form-control category_id" style="width:100%!important;">
                                            <option value="">Select Category</option>
                                            @foreach ($category as $key => $value)
                                            <option value="{{$value->id}}">
                                                {{ $value->name }}
                                            </option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label>Language<span class="text-danger">*</span></label>
                                        <select name="language_id" class="form-control language_id" style="width:100%!important;">
                                            <option value="">Select Language</option>
                                            @foreach ($language as $key => $value)
                                            <option value="{{$value->id}}">
                                                {{ $value->name }}
                                            </option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group ml-5">
                                <label>Portrait Image<span class="text-danger">*</span></label>
                                <div class="avatar-upload">
                                    <div class="avatar-edit">
                                        <input type='file' name="portrait_img" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                        <label for="imageUpload" title="Select File"></label>
                                    </div>
                                    <div class="avatar-preview">
                                        <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreview">
                                    </div>
                                </div>
                                <label class="mt-3 text-gray">Maximum size 2MB.</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Upload Type<span class="text-danger">*</span></label>
                                        <select class="form-control" name="music_upload_type" id="music_upload_type">
                                            <option value="server_video">Server Audio</option>
                                            <option value="external_url">External URL</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 music_box">
                                    <div class="form-group">
                                        <div style="display: block;">
                                            <label>Upload Music</label>
                                            <div id="filelist5"></div>
                                            <div id="container5" style="position: relative;">
                                                <div class="form-group">
                                                    <input type="file" id="uploadFile5" name="uploadFile5" class="form-control import-file p-2">
                                                </div>
                                                <input type="hidden" name="music" id="mp3_file_name5" class="form-control">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-2 mt-4 music_box">
                                    <div class="form-group mt-3">
                                        <a id="upload5" class="btn text-white" style="background-color:#4e45b8;">Upload Files</a>
                                    </div>
                                </div>
                                <div class="col-md-8 musicurl_box">
                                    <div class="form-group">
                                        <label>URL<span class="text-danger">*</span></label>
                                        <input type="text" name="music_url" class="form-control" placeholder="Enter URL">
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Music Duration</label>
                                        <input type="text" id="timePicker" name="music_duration" placeholder="Music Duration" class="form-control">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group ml-5">
                                <label>Landscape Image<span class="text-danger">*</span></label>
                                <div class="avatar-upload-landscape">
                                    <div class="avatar-edit-landscape">
                                        <input type='file' name="landscape_img" id="imageUploadLandscape" accept=".png, .jpg, .jpeg" />
                                        <label for="imageUploadLandscape" title="Select File"></label>
                                    </div>
                                    <div class="avatar-preview-landscape">
                                        <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreviewLandscape">
                                    </div>
                                </div>
                                <label class="mt-3 text-gray">Maximum size 2MB.</label>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="save_music()">{{__('Label.SAVE')}}</button>
                        <a href="{{route('amusic.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        $(".category_id").select2();
        $(".language_id").select2();

        // Time Picker
        var d = new Date();
        d.setHours(0,0,0);
        $('#timePicker').datetimepicker({
            useCurrent: false,
            format:'HH:mm:ss',
            defaultDate: d,
            showClose:true,
            showTodayButton: true,
            icons: {
                up: "fa fa-chevron-up",
                down: "fa fa-chevron-down",
                today: "fa fa-clock fa-regular",
                close: "fa fa-times",
            }
        })

        $(document).ready(function() {
            $(".musicurl_box").hide();
            $('#music_upload_type').change(function() {
                var optionValue = $(this).val();

                if (optionValue == 'server_video') {
                    $(".music_box").show();
                    $(".musicurl_box").hide();
                } else {
                    $(".musicurl_box").show();
                    $(".music_box").hide();
                }
            });
        });

        function save_music() {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#music")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("amusic.store") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'music', '{{ route("amusic.index") }}');
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