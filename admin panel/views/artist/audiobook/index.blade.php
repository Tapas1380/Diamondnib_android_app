@extends('artist.layout.page-app')
@section('page_title', 'Audio Book')

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Audio Book</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Audio Book</li>
                    </ol>
                </div>
            </div>

            <!-- Add Audio Book -->
            <div class="card custom-border-card mt-3">
                <h5 class="card-header">Add Audio Book</h5>
                <div class="card-body">
                    <form id="audiobook" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="">
                        <div class="form-row">
                            <div class="col-md-6">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="title" class="form-control" placeholder="Enter Title" autofocus>
                                        </div>
                                    </div>
                                </div> 
                                <div class="form-row">
                                    <div class="col-md-6">
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
                                    <div class="col-md-6">
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
                                    <label class="ml-5">Portrait Image<span class="text-danger">*</span></label>
                                    <div class="avatar-upload ml-5">
                                        <div class="avatar-edit">
                                            <input type='file' name="portrait_img" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                            <label for="imageUpload" title="Select File"></label>
                                        </div>
                                        <div class="avatar-preview">
                                            <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreview">
                                        </div>
                                    </div>
                                    <label class="mt-3 ml-5 text-gray">Maximum size 2MB.</label>
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
                        <div class="form-row">
                            <div class="col-md-6">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                            <textarea name="description" class="form-control" rows="3" placeholder="Describe Here,"></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group ml-5">
                                    <label class="ml-5">Web Banner Image</label>
                                    <div class="avatar-upload-landscape ml-5">
                                        <div class="avatar-edit-landscape">
                                            <input type='file' name="web_banner_img" id="imageUploadWebBanner" accept=".png, .jpg, .jpeg" />
                                            <label for="imageUploadWebBanner" title="Select File"></label>
                                        </div>
                                        <div class="avatar-preview-landscape">
                                            <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreviewWebBanner">
                                        </div>
                                    </div>
                                    <label class="mt-3 ml-5 text-gray">Maximum size 2MB.</label>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="save_audiobook()">{{__('Label.SAVE')}}</button>
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
                        <input type="text" id="input_search" class="form-control" placeholder="Search Audio Book" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                </div>

                <div class="table-responsive table">
                    <table class="table table-striped text-center table-bordered" id="datatable">
                        <thead>
                            <tr style="background: #F9FAFF;">
                                <th>{{__('Label.#')}}</th>
                                <th>{{__('Label.Image')}}</th>
                                <th>{{__('Label.Title')}}</th>
                                <th>Episode</th>
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
                            <h5 class="modal-title" id="exampleModalLabel">Edit Audio Book</h5>
                            <button type="button" class="close text-dark" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <form id="edit_audiobook" autocomplete="off">
                            <div class="modal-body">
                                <input type="hidden" name="id" id="edit_id">
                                <input type="hidden" name="old_portrait_img" id="edit_old_portrait_img">
                                <input type="hidden" name="old_landscape_img" id="edit_old_landscape_img">
                                <input type="hidden" name="old_web_banner_img" id="edit_old_web_banner_img">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="title" id="edit_title" class="form-control" placeholder="Enter Title">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
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
                                    <div class="col-md-6">
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
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                            <textarea name="description" id="edit_description" class="form-control" rows="1" placeholder="Describe Here,"></textarea>
                                        </div>
                                    </div>
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
                                    <div class="col-md-12">
                                        <div class="form-row">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label>Web Banner Image</label>
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
                                <button type="button" class="btn btn-default mw-120" onclick="update_audiobook()">Update</button>
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
        $(".artist_id").select2();
        $(".category_id").select2();
        $(".language_id").select2();

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
                    url: "{{ route('aaudiobook.index') }}",
                    data: function(d){
                        d.input_search = $('#input_search').val();
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

            $('#input_search').keyup(function() {
                table.draw();
            });
        });

        function save_audiobook(){

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#audiobook")[0]);
                $.ajax({
                    type:'POST',
                    url:'{{ route("aaudiobook.store") }}',
                    data:formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'audiobook', '{{ route("aaudiobook.index") }}');
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

        $(document).on("click", ".edit_audiobook", function() {
            var id = $(this).data('id');
            var artist_id = $(this).data('artist_id');
            var title = $(this).data('title');
            var description = $(this).data('description');
            var portrait_img = $(this).data('portrait_img');
            var landscape_img = $(this).data('landscape_img');
            var web_banner_img = $(this).data('web_banner_img');
            var category_id = $(this).data('category_id');
            var language_id = $(this).data('language_id');

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
        });

        function update_audiobook() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#edit_audiobook")[0]);

                var Edit_Id = $("#edit_id").val();
                var url = '{{ route("aaudiobook.update", ":id") }}';
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
                        get_responce_message(resp, 'edit_audiobook', '{{ route("aaudiobook.index") }}');
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