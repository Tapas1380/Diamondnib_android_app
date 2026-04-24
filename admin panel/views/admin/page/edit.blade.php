@extends('admin.layout.page-app')
@section('page_title', __('Label.Edit_Page'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <!-- summernote background color  -->
        <style>
            :root{
                --page-background-color : {{ $settings['page_background_color'] }} ;
            }
            .note-editable {
                background-color: var(--page-background-color) !important;
            }
        </style>

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('Label.Edit_Page')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="{{ route('page.index') }}">{{__('Label.Page')}}</a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">
                            {{__('Label.Edit Page')}}
                        </li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('page.index') }}" class="btn btn-default mw-120" style="margin-top:-14px">Page</a>
                </div>
            </div>

            <div class="card custom-border-card mt-3">
                <form id="page_update" enctype="multipart/form-data" autocomplete="off">
                    <input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
                    <div class="form-row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                <input name="title" type="text" class="form-control" value="@if($data){{$data->title}}@endif" placeholder="Please Enter Title" autofocus>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group ml-5">
                                <label class="ml-5">Thumbnail image<span class="text-danger">*</span></label>
                                <div class="avatar-upload ml-5">
                                    <div class="avatar-edit">
                                        <input type='file' name="icon" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                        <label for="imageUpload" title="Select File"></label>
                                    </div>
                                    <div class="avatar-preview">
                                        <img src="{{$data->icon}}" alt="upload_img.png" id="imagePreview">
                                    </div>
                                </div>
                                <label class="mt-3 ml-5 text-gray">Maximum size 2MB.</label>
                                <input type="hidden" name="old_icon" value="@if($data){{$data->icon}}@endif">
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                <textarea class="form-control" name="description" id="summernote">@if($data){{$data->description}}@endif</textarea>
                            </div>
                        </div>
                    </div>
                    <div class="border-top mt-2 pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="edit_page()">{{__('Label.UPDATE')}}</button>
                        <a href="{{route('page.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('Label.CANCEL')}}</a>
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

        $(document).ready(function() {
            $('#summernote').summernote({
                placeholder: "Type your text here...",
                height: 500,
                toolbar: [
                    // Style Formatting
                    ['style', ['bold', 'italic', 'underline', 'clear']],
                    // Font Options
                    ['font', ['fontname', 'fontsize']],
                    ['color', ['forecolor']],
                    // Paragraph Formatting
                    ['para', ['ul', 'ol', 'paragraph']],
                    ['height', ['height']],
                    // Insert Options
                    ['insert', ['link', 'picture', 'video']],
                    // Additional Formatting
                    ['table', ['table']],
                    // View Options
                    ['view', ['fullscreen', 'codeview', 'help']],
                ],
                fontSizes: ['8', '10', '12', '14', '16', '18', '20', '22', '24', '26', '28', '30', '32', '34', '36', '38', '40', '44', '48', '52', '56', '60', '64', '68', '72', '78', '82', '86', '90', '94', '100'],
                lineHeights: ['0.2', '0.3', '0.4', '0.5', '0.6', '0.8', '1.0', '1.2', '1.4', '1.5', '1.8', '2.0', '3.0'],   
            });
            // Remove tooltip attributes from toolbar buttons
            $('.note-toolbar button').removeAttr('title data-original-title');
        });

        function edit_page() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if (Check_Admin == 1) {

                $("#dvloader").show();
                var formData = new FormData($("#page_update")[0]);
                $.ajax({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    enctype: 'multipart/form-data',
                    type: 'POST',
                    url: '{{route("page.update", [$data->id])}}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'page_update', '{{ route("page.index") }}');
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