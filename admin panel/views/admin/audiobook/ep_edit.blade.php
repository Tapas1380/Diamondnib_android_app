@extends('admin.layout.page-app')
@section('page_title', 'Edit Episode')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Edit Episode</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('audiobook.index') }}">Audio Book</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('audiobook.episode.index', $audiobook_id) }}">Episodes</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Add Episode</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('audiobook.episode.index', $audiobook_id) }}" class="btn btn-default mw-120" style="margin-top:-14px">Episodes List</a>
                </div>
            </div>

            <form id="episode" enctype="multipart/form-data">
                <div class="card custom-border-card">
                    <h5 class="card-header">Episode</h5>
                    <div class="card-body">
                        <input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
                        <input type="hidden" name="content_id" value="@if($data){{$data->content_id}}@endif">
                        <input type="hidden" name="old_image" value="@if($data){{$data->image}}@endif">
                        <input type="hidden" name="old_audio_type" value="@if($data){{$data->audio_type}}@endif">
                        <input type="hidden" name="old_video_type" value="@if($data){{$data->video_type}}@endif">
                        <input type="hidden" name="old_audio" value="@if($data){{$data->audio}}@endif">
                        <input type="hidden" name="old_video" value="@if($data){{$data->video}}@endif">
                        <div class="form-row">
                            <div class="col-md-9">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="name" value="@if($data){{$data->name}}@endif" class="form-control" placeholder="Enter Name" autofocus>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                            <textarea name="description" class="form-control" rows="2" placeholder="Describe Here,">@if($data){{$data->description}}@endif</textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group ml-5">
                                    <label>Image<span class="text-danger">*</span></label>
                                    <div class="avatar-upload">
                                        <div class="avatar-edit">
                                            <input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                            <label for="imageUpload" title="Select File"></label>
                                        </div>
                                        <div class="avatar-preview">
                                            <img src="{{$data->image}}" alt="upload_img.png" id="imagePreview">
                                        </div>
                                    </div>
                                    <label class="mt-3 text-gray">Maximum size 2MB.</label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card custom-border-card">
                    <h5 class="card-header">Audio</h5>
                    <div class="card-body">
                        <div class="form-row">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Audio Upload Type<span class="text-danger">*</span></label>
                                    <select class="form-control" name="audio_type" id="audio_type">
                                        <option value="1" {{ $data->audio_type == 1 ? 'selected' : ''}}>Server Audio</option>
                                        <option value="2" {{ $data->audio_type == 2 ? 'selected' : ''}}>External URL</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-4 audio_box">
                                <div class="form-group">
                                    <div style="display: block;">
                                        <label>Upload Audio</label>
                                        <div id="filelist1"></div>
                                        <div id="container1" style="position: relative;">
                                            <div class="form-group">
                                                <input type="file" id="uploadFile1" name="uploadFile1" class="form-control import-file p-2">
                                            </div>
                                            <input type="hidden" name="audio" id="mp3_file_name1" class="form-control">
                                        </div>
                                    </div>
                                </div>
                                <label class="text-gray">@if($data->audio_type == 1){{basename($data->audio)}}@endif</label>
                            </div>
                            <div class="col-md-2 mt-4 audio_box">
                                <div class="form-group mt-3">
                                    <a id="upload1" class="btn text-white" style="background-color:#4e45b8;">Upload Files</a>
                                </div>
                            </div>
                            <div class="col-md-6 audio_url_box">
                                <div class="form-group">
                                    <label>Audio URL<span class="text-danger">*</span></label>
                                    <input type="text" name="audio_url" value="@if($data->audio_type != 1){{{$data->audio}}}@endif" class="form-control" placeholder="Enter URL">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Audio Duration</label>
                                    <input type="text" id="timePicker" name="audio_duration" placeholder="Audio Duration" class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Is Paid Audio<span class="text-danger">*</span></label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" name="is_audio_paid" id="is_audio_paid_yes" class="custom-control-input" value="1" {{ $data->is_audio_paid == 1 ? 'checked' : ''}}>
                                            <label class="custom-control-label" for="is_audio_paid_yes">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" name="is_audio_paid" id="is_audio_paid_no" class="custom-control-input" value="0" {{ $data->is_audio_paid == 0 ? 'checked' : ''}}>
                                            <label class="custom-control-label" for="is_audio_paid_no">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2 is_audio_coin">
                                <div class="form-group">
                                    <label>Coin<span class="text-danger">*</span></label>
                                    <input type="number" name="is_audio_coin" value="@if($data){{$data->is_audio_coin}}@endif" class="form-control" placeholder="Enter Coin" min="0" value="0">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card custom-border-card">
                    <h5 class="card-header">Video</h5>
                    <div class="card-body">
                        <div class="form-row">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Video Upload Type<span class="text-danger">*</span></label>
                                    <select class="form-control" name="video_type" id="video_type">
                                        <option value="1" {{ $data->video_type == 1 ? 'selected' : ''}}>Server Audio</option>
                                        <option value="2" {{ $data->video_type == 2 ? 'selected' : ''}}>External URL</option>
                                        <option value="3" {{ $data->video_type == 3 ? 'selected' : ''}}>Youtube</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-4 video_box">
                                <div class="form-group">
                                    <div style="display: block;">
                                        <label>Upload Video</label>
                                        <div id="filelist2"></div>
                                        <div id="container2" style="position: relative;">
                                            <div class="form-group">
                                                <input type="file" id="uploadFile2" name="uploadFile2" class="form-control import-file p-2">
                                            </div>
                                            <input type="hidden" name="video" id="mp3_file_name2" class="form-control">
                                        </div>
                                    </div>
                                </div>
                                <label class="text-gray">@if($data->video_type == 1){{basename($data->video)}}@endif</label>
                            </div>
                            <div class="col-md-2 mt-4 video_box">
                                <div class="form-group mt-3">
                                    <a id="upload2" class="btn text-white" style="background-color:#4e45b8;">Upload Files</a>
                                </div>
                            </div>
                            <div class="col-md-6 video_url_box">
                                <div class="form-group">
                                    <label>Video URL<span class="text-danger">*</span></label>
                                    <input type="text" name="video_url" value="@if($data->video_type != 1){{{$data->video}}}@endif" class="form-control" placeholder="Enter URL">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Video Duration</label>
                                    <input type="text" id="timePicker1" name="video_duration" placeholder="Video Duration" class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>Is Paid Video<span class="text-danger">*</span></label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" name="is_video_paid" id="is_video_paid_yes" class="custom-control-input" value="1" {{ $data->is_video_paid == 1 ? 'checked' : ''}}>
                                            <label class="custom-control-label" for="is_video_paid_yes">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" name="is_video_paid" id="is_video_paid_no" class="custom-control-input" value="0" {{ $data->is_video_paid == 0 ? 'checked' : ''}}>
                                            <label class="custom-control-label" for="is_video_paid_no">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2 is_video_coin">
                                <div class="form-group">
                                    <label>Coin<span class="text-danger">*</span></label>
                                    <input type="number" name="is_video_coin" value="@if($data){{$data->is_video_coin}}@endif" class="form-control" placeholder="Enter Coin" min="0" value="0">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-right">
                    <button type="button" class="btn btn-default mw-120" onclick="save_episode()">{{__('Label.SAVE')}}</button>
                    <a href="{{route('audiobook.episode.index', $audiobook_id)}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                </div>
            </form>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        var duration = '<?php echo $data->audio_duration; ?>';

        function msToHours(duration) {
            var hours = Math.floor((duration / (1000 * 60 * 60)) % 24);
            hours = (hours < 10) ? "0" + hours : hours;
            return hours;
        }

        function msToMinutes(duration) {
            var minutes = Math.floor((duration / (1000 * 60)) % 60),
                minutes = (minutes < 10) ? "0" + minutes : minutes;
            return minutes;
        }

        function msToSeconds(duration) {
            var seconds = Math.floor((duration / 1000) % 60),
                seconds = (seconds < 10) ? "0" + seconds : seconds;
            return seconds;
        }
        let hours = msToHours(duration);
        let minutes = msToMinutes(duration);
        let seconds = msToSeconds(duration);
        var date = new Date();
        date.setHours(hours, minutes, seconds);

        $('#timePicker').datetimepicker({
            useCurrent: false,
            format: 'HH:mm:ss',
            defaultDate: date,
            showClose: true,
            showTodayButton: true,
            icons: {
                up: "fa fa-chevron-up",
                down: "fa fa-chevron-down",
                today: "fa fa-clock fa-regular",
                close: "fa fa-times",
            }
        })

        var duration1 = '<?php echo $data->video_duration; ?>';
        let hours1 = msToHours(duration1);
        let minutes1 = msToMinutes(duration1);
        let seconds1 = msToSeconds(duration1);
        var date1 = new Date();
        date1.setHours(hours1, minutes1, seconds1);

        $('#timePicker1').datetimepicker({
            useCurrent: false,
            format: 'HH:mm:ss',
            defaultDate: date1,
            showClose: true,
            showTodayButton: true,
            icons: {
                up: "fa fa-chevron-up",
                down: "fa fa-chevron-down",
                today: "fa fa-clock fa-regular",
                close: "fa fa-times",
            }
        })

        $(document).ready(function() {

            // Audio
            var audio_type = "<?php echo $data->audio_type; ?>";
            if (audio_type == 1) {
                $(".audio_url_box").hide();
            } else {
                $(".audio_box").hide();
            }
            $('#audio_type').change(function() {
                var optionValue = $(this).val();

                if (optionValue == 1) {
                    $(".audio_box").show();
                    $(".audio_url_box").hide();
                } else {
                    $(".audio_url_box").show();
                    $(".audio_box").hide();
                }
            });
            var is_audio_paid = "<?php echo $data->is_audio_paid; ?>";
            if(is_audio_paid == 1){
                $(".is_audio_coin").show();
            } else {
                $(".is_audio_coin").hide();
            }
            $('input[type=radio][name=is_audio_paid]').change(function() {
                if (this.value == 1) {
                    $(".is_audio_coin").show();
                }
                else if (this.value == 0) {
                    $(".is_audio_coin").hide();
                }
            });

            // Video
            var video_type = "<?php echo $data->video_type; ?>";
            if (video_type == 1) {
                $(".video_url_box").hide();
            } else {
                $(".video_box").hide();
            }
            $('#video_type').change(function() {
                var optionValue = $(this).val();

                if (optionValue == 1) {
                    $(".video_box").show();
                    $(".video_url_box").hide();
                } else {
                    $(".video_url_box").show();
                    $(".video_box").hide();
                }
            });
            var is_video_paid = "<?php echo $data->is_video_paid; ?>";
            if(is_video_paid == 1){
                $(".is_video_coin").show();
            } else {
                $(".is_video_coin").hide();
            }
            $('input[type=radio][name=is_video_paid]').change(function() {
                if (this.value == 1) {
                    $(".is_video_coin").show();
                }
                else if (this.value == 0) {
                    $(".is_video_coin").hide();
                }
            });
        });

        function save_episode() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if (Check_Admin == 1) {

                $("#dvloader").show();
                var formData = new FormData($("#episode")[0]);
                $.ajax({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    enctype: 'multipart/form-data',
                    type: 'POST',
                    url: '{{route("audiobook.episode.update", [$audiobook_id, $data->id])}}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'episode', '{{ route("audiobook.episode.index", $audiobook_id) }}');
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