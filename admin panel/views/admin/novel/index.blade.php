@extends('admin.layout.page-app')
@section('page_title', 'Novel')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Novel</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Novel</li>
                    </ol>
                </div>
            </div>

            <!-- Add Novel -->
            <div class="card custom-border-card mt-3">
                <h5 class="card-header">Add Novel</h5>
                <div class="card-body">
                    <form id="novel" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="">
                        <div class="form-row">
                            <div class="col-md-7">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="title" class="form-control" placeholder="Enter Title" autofocus>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Artist<span class="text-danger">*</span></label>
                                            <select name="artist_id" class="form-control artist_id" style="width:100%!important;">
                                                <option value="">Select Artist</option>
                                                @foreach ($artist as $key => $value)
                                                    <option value="{{$value->id}}">
                                                        {{ $value->user_name }}
                                                    </option>
                                                @endforeach
                                            </select>
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
                                    </div>
                                    <div class="col-md-4">
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
                                <div class="form-row">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <div style="display: block;">
                                                <label>Upload Full Book</label>
                                                <div id="filelist3"></div>
                                                <div id="container3" style="position: relative;">
                                                    <div class="form-group">
                                                        <input type="file" id="uploadFile3" name="uploadFile3" class="form-control import-file p-2">
                                                    </div>
                                                    <input type="hidden" name="full_novel" id="mp3_file_name3" class="form-control">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-2 mt-4">
                                        <div class="form-group mt-3">
                                            <a id="upload3" class="btn text-white" style="background-color:#4e45b8;">Upload Files</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
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
                            <div class="col-md-3">
                                <div class="form-group">
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
                        <div class="form-row">
                            <div class="col-md-7">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                            <textarea name="description" class="form-control" rows="1" placeholder="Describe Here,"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Is Paid Full Book<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="is_paid_novel" id="is_paid_novel_yes" class="custom-control-input" value="1">
                                                    <label class="custom-control-label" for="is_paid_novel_yes">{{__('Label.Yes')}}</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="is_paid_novel" id="is_paid_novel_no" class="custom-control-input" value="0" checked>
                                                    <label class="custom-control-label" for="is_paid_novel_no">{{__('Label.No')}}</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-5 novel_coin">
                                        <div class="form-group">
                                            <label>Coin<span class="text-danger">*</span></label>
                                            <input type="number" name="novel_coin" class="form-control" placeholder="Enter Coin" min="0" value="0">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Web Banner Image</label>
                                    <div class="avatar-upload-landscape">
                                        <div class="avatar-edit-landscape">
                                            <input type='file' name="web_banner_img" id="imageUploadWebBanner" accept=".png, .jpg, .jpeg" />
                                            <label for="imageUploadWebBanner" title="Select File"></label>
                                        </div>
                                        <div class="avatar-preview-landscape">
                                            <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreviewWebBanner">
                                        </div>
                                    </div>
                                    <label class="mt-3 text-gray">Maximum size 2MB.</label>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="save_novel()">{{__('Label.SAVE')}}</button>
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        </div>
                    </form>
                </div>
            </div>

            <!-- Search && Table -->
            <div class="card custom-border-card mt-3">
                <div class="page-search mb-3">
                    <div class="input-group" title="Search">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                        </div>
                        <input type="text" id="input_search" class="form-control" placeholder="Search Novel" aria-label="Search" aria-describedby="basic-addon1">
                    </div>  
                    <div class="sorting" style="width: 40%;">
                        <label>Sort by :</label>
                        <select class="form-control artist_id" name="input_artist" id="input_artist">
                            <option value="0" selected>All Artist</option>
                            @foreach ($artist as $key => $value)
                                <option value="{{$value->id}}">
                                    {{ $value->user_name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div class="table-responsive table">
                    <table class="table table-striped text-center table-bordered" id="datatable">
                        <thead>
                            <tr style="background: #F9FAFF;">
                                <th>{{__('Label.#')}}</th>
                                <th>{{__('Label.Image')}}</th>
                                <th>Artist</th>
                                <th>{{__('Label.Title')}}</th>
                                <th>Chapters</th>
                                <th>Status</th>
                                <th>{{__('Label.Action')}}</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>

            <!-- Edit Model -->
            <div class="modal fade" id="EditModel" data-backdrop="static" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLabel">Edit Novel</h5>
                            <button type="button" class="close text-dark" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <form id="edit_novel" autocomplete="off">
                            <div class="modal-body">
                                <input type="hidden" name="id" id="edit_id">
                                <input type="hidden" name="old_portrait_img" id="edit_old_portrait_img">
                                <input type="hidden" name="old_landscape_img" id="edit_old_landscape_img">
                                <input type="hidden" name="old_web_banner_img" id="edit_old_web_banner_img">
                                <input type="hidden" name="old_full_novel" id="edit_old_full_novel">
                                <div class="form-row">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="title" id="edit_title" class="form-control" placeholder="Enter Title">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Category<span class="text-danger">*</span></label>
                                            <select name="category_id" id="edit_category_id" class="form-control category_id" style="width:100%!important;">
                                                <option value="">Select Category</option>
                                                @foreach ($category as $key => $value)
                                                    <option value="{{$value->id}}">
                                                        {{ $value->name }}
                                                    </option>
                                                @endforeach
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <label>Artist<span class="text-danger">*</span></label>
                                            <select name="artist_id" id="edit_artist_id" class="form-control artist_id" style="width:100%!important;">
                                                <option value="">Select Artist</option>
                                                @foreach ($artist as $key => $value)
                                                    <option value="{{$value->id}}">
                                                        {{ $value->user_name }}
                                                    </option>
                                                @endforeach
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Language<span class="text-danger">*</span></label>
                                            <select name="language_id" id="edit_language_id" class="form-control language_id" style="width:100%!important;">
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
                                <div class="form-row">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <div style="display: block;">
                                                <label>Upload Full Book</label>
                                                <div id="filelist4"></div>
                                                <div id="container4" style="position: relative;">
                                                    <div class="form-group">
                                                        <input type="file" id="uploadFile4" name="uploadFile4" class="form-control import-file p-2">
                                                    </div>
                                                    <input type="hidden" name="full_novel" id="mp3_file_name4" class="form-control">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-2 mt-4">
                                        <div class="form-group mt-3">
                                            <a id="upload4" class="btn text-white" style="background-color:#4e45b8;">Upload Files</a>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                            <textarea name="description" id="edit_description" class="form-control" rows="1" placeholder="Describe Here,"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Is Paid Full Book<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="edit_is_paid_novel" id="edit_is_paid_novel_yes" class="custom-control-input" value="1">
                                                    <label class="custom-control-label" for="edit_is_paid_novel_yes">{{__('Label.Yes')}}</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="edit_is_paid_novel" id="edit_is_paid_novel_no" class="custom-control-input" value="0">
                                                    <label class="custom-control-label" for="edit_is_paid_novel_no">{{__('Label.No')}}</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 edit_novel_coin">
                                        <div class="form-group">
                                            <label>Coin<span class="text-danger">*</span></label>
                                            <input type="number" name="novel_coin" id="edit_novel_coin" class="form-control" placeholder="Enter Coin" min="0">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-row">
                                            <div class="col-md-6">
                                                <div class="form-group ml-3">
                                                    <label class="">Portrait Image<span class="text-danger">*</span></label>
                                                    <div class="avatar-upload">
                                                        <div class="avatar-edit">
                                                            <input type='file' name="portrait_img" id="imageUploadModel" accept=".png, .jpg, .jpeg" />
                                                            <label for="imageUploadModel" title="Select File"></label>
                                                        </div>
                                                        <div class="avatar-preview">
                                                            <img src="" alt="upload_img.png" id="imagePreviewModel">
                                                        </div>
                                                    </div>
                                                    <label class="mt-3 text-gray">Maximum size 2MB.</label>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label>Landscape Image<span class="text-danger">*</span></label>
                                                    <div class="avatar-upload-landscape">
                                                        <div class="avatar-edit-landscape">
                                                            <input type='file' name="landscape_img" id="imageUploadLandscapeModel" accept=".png, .jpg, .jpeg" />
                                                            <label for="imageUploadLandscapeModel" title="Select File"></label>
                                                        </div>
                                                        <div class="avatar-preview-landscape">
                                                            <img src="" alt="upload_img.png" id="imagePreviewLandscapeModel">
                                                        </div>
                                                    </div>
                                                    <label class="mt-3 text-gray">Maximum size 2MB.</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-row">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label>Web Banner Image<span class="text-danger">*</span></label>
                                                    <div class="avatar-upload-landscape">
                                                        <div class="avatar-edit-landscape">
                                                            <input type='file' name="web_banner_img" id="imageUploadWebBannerModel" accept=".png, .jpg, .jpeg" />
                                                            <label for="imageUploadWebBannerModel" title="Select File"></label>
                                                        </div>
                                                        <div class="avatar-preview-landscape">
                                                            <img src="" alt="upload_img.png" id="imagePreviewWebBannerModel">
                                                        </div>
                                                    </div>
                                                    <label class="mt-3 text-gray">Maximum size 2MB.</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default mw-120" onclick="update_novel()">Update</button>
                                <button type="button" class="btn btn-cancel mw-120" data-dismiss="modal">Close</button>
                                <input type="hidden" name="_method" value="PATCH">
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>

        // Sidebar Scroll Down
        sidebar_down(500);

        $(".artist_id").select2();
        $(".category_id").select2();
        $(".language_id").select2();

        $(".novel_coin").hide();
        $('input[type=radio][name=is_paid_novel]').change(function() {
            if (this.value == 1) {
                $(".novel_coin").show();
            }
            else if (this.value == 0) {
                $(".novel_coin").hide();
            }
        });

        $(document).ready(function() {
            var table = $('#datatable').DataTable({
                dom: "<'top'f>rt<'row'<'col-2'i><'col-1'l><'col-9'p>>",
                searching: false,
                responsive: true,
                autoWidth: false,
                processing: true,
                serverSide: true,
                lengthMenu: [
                    [10, 100, 500, -1],
                    [10, 100, 500, "All"]
                ],
                language: {
                    paginate: {
                        previous: "<i class='fa-solid fa-chevron-left'></i>",
                        next: "<i class='fa-solid fa-chevron-right'></i>"
                    }
                },
                ajax:
                    {
                    url: "{{ route('novel.index') }}",
                    data: function(d){
                        d.input_search = $('#input_search').val();
                        d.input_artist = $('#input_artist').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'portrait_img',
                        name: 'portrait_img',
                        orderable: false,
                        searchable: false,
                        render: function(data, type, full, meta) {
                            return "<a href='" + data + "' target='_blank' title='Watch'><img src='" + data + "' class='img-thumbnail' style='height:55px; width:55px'></a>";
                        },
                    },
                    {
                        data: 'artist.user_name',
                        name: 'artist.user_name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'title',
                        name: 'title',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'episode',
                        name: 'episode',
                        orderable: false,
                        searchable: false
                    },
                    {
                        data: 'status',
                        name: 'status',
                        orderable: false,
                        searchable: false
                    },
                    {
                        data: 'action',
                        name: 'action',
                        orderable: false,
                        searchable: false
                    },
                ],
            });

            $('#input_artist').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            });
        });

        function save_novel(){
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#novel")[0]);
                $.ajax({
                    type:'POST',
                    url:'{{ route("novel.store") }}',
                    data:formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'novel', '{{ route("novel.index") }}');
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

        $(document).on("click", ".edit_novel", function() {
            var id = $(this).data('id');
            var title = $(this).data('title');
            var artist_id = $(this).data('artist_id');
            var category_id = $(this).data('category_id');
            var language_id = $(this).data('language_id');
            var portrait_img = $(this).data('portrait_img');
            var landscape_img = $(this).data('landscape_img');
            var web_banner_img = $(this).data('web_banner_img');
            var description = $(this).data('description');
            var full_novel = $(this).data('full_novel');
            var is_paid_novel = $(this).data('is_paid_novel');
            var novel_coin = $(this).data('novel_coin');

            $(".modal-body #edit_id").val(id);
            $(".modal-body #edit_title").val(title);
            $(".modal-body #edit_description").val(description);
            $(".modal-body #edit_artist_id").val(artist_id).change();
            $(".modal-body #edit_category_id").val(category_id).change();
            $(".modal-body #edit_language_id").val(language_id).change();
            $(".modal-body #imagePreviewModel").attr("src", portrait_img);
            $(".modal-body #imagePreviewLandscapeModel").attr("src", landscape_img);
            $(".modal-body #imagePreviewWebBannerModel").attr("src", web_banner_img);
            $(".modal-body #edit_old_portrait_img").val(portrait_img);
            $(".modal-body #edit_old_landscape_img").val(landscape_img);
            $(".modal-body #edit_old_web_banner_img").val(web_banner_img);
            $(".modal-body #edit_old_full_novel").val(full_novel);
            $(".modal-body #edit_novel_coin").val(novel_coin);

            if(is_paid_novel == 1){
                $('#edit_is_paid_novel_yes').prop('checked', true);
                $(".edit_novel_coin").show();
            } else {
                $('#edit_is_paid_novel_no').prop('checked', true);
                $(".edit_novel_coin").hide();
            }

            $('input[type=radio][name=edit_is_paid_novel]').change(function() {
                if (this.value == 1) {
                    $(".edit_novel_coin").show();
                }
                else if (this.value == 0) {
                    $(".edit_novel_coin").hide();
                }
            });
        });

        function update_novel() {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#edit_novel")[0]);

                var Edit_Id = $("#edit_id").val();

                var url = '{{ route("novel.update", ":id") }}';
                    url = url.replace(':id', Edit_Id);

                $.ajax({
                    headers: {
					    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
				    },
				    enctype: 'multipart/form-data',
                    type: 'POST',
                    url: url,
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();

                        if(resp.status == 200){
                            $('#EditModel').modal('toggle');
                        }
                        get_responce_message(resp, 'edit_novel', '{{ route("novel.index") }}');
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

        function change_status(id, status) {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var url = "{{route('novel.show', '')}}" + "/" + id;
                $.ajax({
                    type: "GET",
                    url: url,
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    data: id,
                    success: function(resp) {
                        $("#dvloader").hide();
                        if (resp.status == 200) {
                            if (resp.Status_Code == 1) {

                                $('#' + id).text('Show');
                                $('#' + id).css({
                                    "background": "#058f00",
                                    "font-weight":"bold",
                                    "color": "white",
                                    "border": "none",
                                    "outline": "none",
                                    "padding": "5px 15px",
                                    "border-radius": "5px",
                                    "cursor": "pointer",
                                });
                            } else {

                                $('#' + id).text('Hide');
                                $('#' + id).css({
                                    "background": "#e3000b",
                                    "color": "white",
                                    "border": "none",
                                    "outline": "none",
                                    "padding": "5px 20px",
                                    "border-radius": "5px",
                                    "cursor": "pointer",
                                });
                            }
                        } else {
                            toastr.error(resp.errors);
                        }
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        };
    </script>
@endsection