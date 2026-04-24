@extends('admin.layout.page-app')
@section('page_title', 'Artist')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Artist</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Artist</li>
                    </ol>
                </div>
            </div>

            <!-- Add Artist -->
            <div class="card custom-border-card mt-3">
                <h5 class="card-header">Add Artist</h5>
                <div class="card-body">
                    <form id="artist" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="">
                        <div class="form-row">
                            <div class="col-md-9">
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>User Name<span class="text-danger">*</span></label>
                                            <input type="text" name="user_name" class="form-control" placeholder="Enter User Name" autofocus>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('Label.Password')}}<span class="text-danger">*</span></label>
                                            <input type="password" name="password" class="form-control" placeholder="Enter Password">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Instagram URL<span class="text-danger">*</span></label>
                                            <input type="text" name="instagram_url" class="form-control" placeholder="Enter URL">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Facebook URL<span class="text-danger">*</span></label>
                                            <input type="text" name="facebook_url" class="form-control" placeholder="Enter URL">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Bio')}}<span class="text-danger">*</span></label>
                                            <textarea name="bio" rows="1" class="form-control" placeholder="Describe Your Self..."></textarea>
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
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="save_artist()">{{__('Label.SAVE')}}</button>
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
                        <input type="text" id="input_search" class="form-control" placeholder="Search Artist" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                </div>
                <div class="table-responsive table">
                    <table class="table table-striped text-center table-bordered" id="datatable">
                        <thead>
                            <tr style="background: #F9FAFF;">
                                <th>{{__('Label.#')}}</th>
                                <th>{{__('Label.Image')}}</th>
                                <th>User Name</th>
                                <th>{{__('Label.Action')}}</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>

            <!-- Edit Model -->
            <div class="modal fade" id="EditModel" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLabel">Edit Artist</h5>
                            <button type="button" class="close text-dark" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <form id="edit_artist" autocomplete="off">
                            <div class="modal-body">
                                <div class="form-row">
                                    <div class="col-md-8">
                                        <div class="form-row">
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label>User Name<span class="text-danger">*</span></label>
                                                    <input type="text" name="user_name" id="edit_user_name" class="form-control" placeholder="Enter User Name">
                                                </div>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label>{{__('Label.Bio')}}<span class="text-danger">*</span></label>
                                                    <textarea name="bio" rows="1" id="edit_bio" class="form-control" placeholder="Describe Your Self..."></textarea>
                                                </div>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label>Instagram URL<span class="text-danger">*</span></label>
                                                    <input type="text" name="instagram_url" id="edit_instagram_url" class="form-control" placeholder="Enter URL">
                                                </div>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label>Facebook URL<span class="text-danger">*</span></label>
                                                    <input type="text" name="facebook_url" id="edit_facebook_url" class="form-control" placeholder="Enter URL">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group ml-3">
                                            <label class="">Image<span class="text-danger">*</span></label>
                                            <div class="avatar-upload">
                                                <div class="avatar-edit">
                                                    <input type='file' name="image" id="imageUploadModel" accept=".png, .jpg, .jpeg" />
                                                    <label for="imageUploadModel" title="Select File"></label>
                                                </div>
                                                <div class="avatar-preview">
                                                    <img src="" alt="upload_img.png" id="imagePreviewModel">
                                                </div>
                                            </div>
                                            <label class="mt-3 text-gray">Maximum size 2MB.</label>
                                        </div>
                                    </div>
                                </div>
                                <input type="hidden" name="id" id="edit_id">
                                <input type="hidden" name="old_image" id="edit_old_image">
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default mw-120" onclick="update_artist()">Update</button>
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
                ajax: {
                    url: "{{ route('artist.index') }}",
                    data: function(d) {
                        d.input_search = $('#input_search').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'image',
                        name: 'image',
                        orderable: false,
                        searchable: false,
                        render: function(data, type, full, meta) {
                            return "<a href='" + data + "' target='_blank' title='Watch'><img src='" + data + "' class='rounded-circle' style='height:55px; width:55px'></a>";
                        },
                    },
                    {
                        data: 'user_name',
                        name: 'user_name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'action',
                        name: 'action',
                        orderable: false,
                        searchable: false
                    },
                ],
            });

            $('#input_type').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            });
        });

        function save_artist() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if (Check_Admin == 1) {

                $("#dvloader").show();
                var formData = new FormData($("#artist")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("artist.store") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'artist', '{{ route("artist.index") }}');
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

        $(document).on("click", ".edit_artist", function() {
            var id = $(this).data('id');
            var user_name = $(this).data('user_name');
            var image = $(this).data('image');
            var bio = $(this).data('bio');
            var facebook_url = $(this).data('facebook_url');
            var instagram_url = $(this).data('instagram_url');

            $(".modal-body #edit_id").val(id);
            $(".modal-body #edit_user_name").val(user_name);
            $(".modal-body #imagePreviewModel").attr("src", image);
            $(".modal-body #edit_old_image").val(image);
            $(".modal-body #edit_bio").val(bio);
            $(".modal-body #edit_facebook_url").val(facebook_url);
            $(".modal-body #edit_instagram_url").val(instagram_url);
        });

        function update_artist() {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if (Check_Admin == 1) {

                $("#dvloader").show();
                var formData = new FormData($("#edit_artist")[0]);

                var Edit_Id = $("#edit_id").val();
                var url = '{{ route("artist.update", ":id") }}';
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

                        if (resp.status == 200) {
                            $('#EditModel').modal('toggle');
                        }
                        get_responce_message(resp, 'edit_artist', '{{ route("artist.index") }}');
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