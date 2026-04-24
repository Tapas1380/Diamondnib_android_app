@extends('admin.layout.page-app')
@section('page_title',  'Add Chapter')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Add Chapter</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('novel.index') }}">Novel</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('novel.episode.index', $novel_id) }}">Chapters</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Add Chapter</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('novel.episode.index', $novel_id) }}" class="btn btn-default mw-120" style="margin-top:-14px">Chapters List</a>
                </div>
            </div>

            <div class="card custom-border-card">
                <form id="episode" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="">
                    <input type="hidden" name="content_id" value="@if($novel_id){{$novel_id}}@endif">
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>{{__('Label.Name')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="name" class="form-control" placeholder="Enter Name" autofocus>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                        <textarea name="description" class="form-control" rows="2" placeholder="Describe Here,"></textarea>
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
                                        <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreview">
                                    </div>
                                </div>
                                <label class="mt-3 ml-5 text-gray">Maximum size 2MB.</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <div style="display: block;">
                                    <label>Upload Chapter</label>
                                    <div id="filelist3"></div>
                                    <div id="container3" style="position: relative;">
                                        <div class="form-group">
                                            <input type="file" id="uploadFile3" name="uploadFile3" class="form-control import-file p-2">
                                        </div>
                                        <input type="hidden" name="book" id="mp3_file_name3" class="form-control">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-2 mt-4">
                            <div class="form-group mt-3">
                                <a id="upload3" class="btn text-white" style="background-color:#4e45b8;">Upload Files</a>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Is Paid<span class="text-danger">*</span></label>
                                <div class="radio-group">
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="is_book_paid" id="is_book_paid_yes" class="custom-control-input" value="1">
                                        <label class="custom-control-label" for="is_book_paid_yes">{{__('Label.Yes')}}</label>
                                    </div>
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="is_book_paid" id="is_book_paid_no" class="custom-control-input" value="0" checked>
                                        <label class="custom-control-label" for="is_book_paid_no">{{__('Label.No')}}</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-2 is_book_coin">
                            <div class="form-group">
                                <label>Coin<span class="text-danger">*</span></label>
                                <input type="number" name="is_book_coin" class="form-control" placeholder="Enter Coin" min="0" value="0">
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="save_episode()">{{__('Label.SAVE')}}</button>
                        <a href="{{route('novel.episode.index', $novel_id)}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
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
        sidebar_down(500);

        $(document).ready(function() {
            $(".is_book_coin").hide();
            $('input[type=radio][name=is_book_paid]').change(function() {
                if (this.value == 1) {
                    $(".is_book_coin").show();
                }
                else if (this.value == 0) {
                    $(".is_book_coin").hide();
                }
            });
        });

		function save_episode(){
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#episode")[0]);
                $.ajax({
                    type:'POST',
                    url:'{{ route("novel.episode.save") }}',
                    data:formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'episode', '{{ route("novel.episode.index", $novel_id) }}');
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