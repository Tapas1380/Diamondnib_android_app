@extends('admin.layout.page-app')
@section('page_title', 'Audio Book Section')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Audio Book Section</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-11">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Audio Book Section</li>
                    </ol>
                </div>
                <div class="col-sm-1 d-flex justify-content-start mb-3" title="Sortable">
                    <button type="button" data-toggle="modal" data-target="#sortableModal" onclick="sortableBTN()" class="btn btn-default" style="border-radius: 10px;">
                        <i class="fa-solid fa-sort fa-1x"></i>
                    </button>
                </div>
            </div>

            <ul class="tabs nav nav-pills custom-tabs inline-tabs " id="pills-tab" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="app-tab" onclick="Top_Content('1', '0', '0')" data-is_home_screen="1"
                        data-id="0" data-toggle="pill" href="#app" role="tab" aria-controls="app" aria-selected="true">Home</a>
                </li>
                @for ($i = 0; $i < count($category); $i++) 
                <li class="nav-item">
                    <a class="nav-link" id="{{$category[$i]['name']}}-tab" onclick="Top_Content('2' , '{{$category[$i]['id']}}', '{{$category[$i]['type']}}')" data-is_home_screen="2" data-id="{{$category[$i]['id']}}" 
                        data-toggle="pill" href="#{{$category[$i]['name']}}" role="tab" aria-controls="{{$category[$i]['name']}}" aria-selected="true">{{ $category[$i]['name']}}</a>
                </li>
                @endfor
            </ul>

            <div class="tab-content" id="pills-tabContent">
                <div class="tab-pane fade show active" id="app" role="tabpanel" aria-labelledby="app-tab">
                    <div class="card custom-border-card">
                        <h5 class="card-header">Section</h5>
                        <div class="card-body">
                            <form id="save_content_section" enctype="multipart/form-data">
                                <input type="hidden" name="id" value="">
                                <div class="form-row">
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="title" class="form-control" placeholder="Enter Title" autofocus>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Short Title<span class="text-danger">*</span></label>
                                            <input type="text" name="short_title" class="form-control" placeholder="Enter Short Title">
                                        </div>
                                    </div>
                                    <div class="col-md-3 content_type_drop">
                                        <div class="form-group">
                                            <label>Content Type<span class="text-danger">*</span></label>
                                            <select name="content_type" class="form-control" id="content_type">
                                                <option value="">Select Type</option>
                                                <option value="1">Audio Book</option>
                                                <!-- <option value="2">Novel</option> -->
                                                <option value="3">Category</option>
                                                <option value="4">Language</option>
                                                <option value="5">Artist</option>
                                                <!-- <option value="6">Continue Playing</option> -->
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3 screen_layout_drop">
                                        <div class="form-group">
                                            <label>Screen Layout<span class="text-danger">*</span></label>
                                            <select name="screen_layout" class="form-control" id="screen_layout">
                                                <option value="">Select Screen Layout</option>
                                                <option value="grid_view">Grid View</option>
                                                <option value="list_view">List View</option>
                                                <option value="portrait">Portrait</option>
                                                <option value="landscape">Landscape</option>
                                                <option value="small_square">Small Square</option>
                                                <option value="big_square">Big Square</option>
                                                <option value="details_square">Details Square</option>
                                                <option value="category">Category</option>
                                                <option value="language">Language</option>
                                                <option value="round">Round</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-3 artist_drop">
                                        <div class="form-group">
                                            <label>Artist<span class="text-danger">*</span></label>
                                            <select name="artist_id" class="form-control" id="artist_id">
                                                <option value="0">All Artist</option>
                                                @for ($i = 0; $i < count($artist); $i++) 
                                                <option value="{{ $artist[$i]['id'] }}">
                                                    {{ $artist[$i]['user_name'] }}
                                                </option>
                                                @endfor
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3 category_drop">
                                        <div class="form-group">
                                            <label>Category<span class="text-danger">*</span></label>
                                            <select name="category_id" class="form-control" id="category_id">
                                                <option value="0">All Category</option>
                                                @for ($i = 0; $i < count($category); $i++) 
                                                <option value="{{ $category[$i]['id'] }}">
                                                    {{ $category[$i]['name'] }}
                                                </option>
                                                @endfor
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3 language_drop">
                                        <div class="form-group">
                                            <label>Language<span class="text-danger">*</span></label>
                                            <select name="language_id" class="form-control" id="language_id">
                                                <option value="0">All Language</option>
                                                @for ($i = 0; $i < count($language); $i++) 
                                                <option value="{{ $language[$i]['id'] }}">
                                                    {{ $language[$i]['name'] }}
                                                </option>
                                                @endfor
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3 no_of_content_drop">
                                        <div class="form-group">
                                            <label>No of Content<span class="text-danger">*</span></label>
                                            <input type="number" min="1" value="1" name="no_of_content" class="form-control" placeholder="Enter Number Of Content">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-3 order_by_upload_drop">
                                        <div class="form-group">
                                            <label>Order by Upload<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_upload" id="order_by_upload_yes" class="custom-control-input" value="1" checked>
                                                    <label class="custom-control-label" for="order_by_upload_yes">Asc</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_upload" id="order_by_upload_no" class="custom-control-input" value="2">
                                                    <label class="custom-control-label" for="order_by_upload_no">Desc</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3 order_by_play_drop">
                                        <div class="form-group">
                                            <label>Order by Play<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_play" id="order_by_play_yes" class="custom-control-input" value="1" checked>
                                                    <label class="custom-control-label" for="order_by_play_yes">Asc</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_play" id="order_by_play_no" class="custom-control-input" value="2">
                                                    <label class="custom-control-label" for="order_by_play_no">Desc</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3 view_all_drop">
                                        <div class="form-group">
                                            <label>View All<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="view_all" id="view_all_yes" class="custom-control-input" value="1" checked>
                                                    <label class="custom-control-label" for="view_all_yes">Yes</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="view_all" id="view_all_no" class="custom-control-input" value="0">
                                                    <label class="custom-control-label" for="view_all_no">No</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="border-top pt-3 text-right">
                                    <button type="button" class="btn btn-default mw-120" onclick="save_section()">{{__('Label.SAVE')}}</button>
                                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="after-add-more"></div>
                </div>
            </div>

            <!-- Modal -->
            <div class="modal fade" id="exampleModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLabel">Edit Section</h5>
                            <button type="button" class="close text-dark" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <form id="edit_content_section" enctype="multipart/form-data">
                            <div class="modal-body">
                                <input type="hidden" name="id" id="edit_id" value="">
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('Label.Title')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="title" id="edit_title" class="form-control" placeholder="Enter Title">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Short Title<span class="text-danger">*</span></label>
                                            <input type="text" name="short_title" id="edit_short_title" class="form-control" placeholder="Enter Short Title">
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_content_type_drop">
                                        <div class="form-group">
                                            <label>Content Type<span class="text-danger">*</span></label>
                                            <select name="content_type" class="form-control" id="edit_content_type">
                                                <option value="">Select Type</option>
                                                <option value="1">Audio Book</option>
                                                <!-- <option value="2">Novel</option> -->
                                                <option value="3">Category</option>
                                                <option value="4">Language</option>
                                                <option value="5">Artist</option>
                                                <!-- <option value="6">Continue Playing</option> -->
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_screen_layout_drop">
                                        <div class="form-group">
                                            <label>Screen Layout<span class="text-danger">*</span></label>
                                            <select name="screen_layout" class="form-control" id="edit_screen_layout">
                                                <option value="">Select Screen Layout</option>
                                                <option value="grid_view">Grid View</option>
                                                <option value="list_view">List View</option>
                                                <option value="portrait">Portrait</option>
                                                <option value="landscape">Landscape</option>
                                                <option value="small_square">Small Square</option>
                                                <option value="big_square">Big Square</option>
                                                <option value="details_square">Details Square</option>
                                                <option value="category">Category</option>
                                                <option value="language">Language</option>
                                                <option value="round">Round</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_artist_drop">
                                        <div class="form-group">
                                            <label>Artist<span class="text-danger">*</span></label>
                                            <select name="artist_id" class="form-control" id="edit_artist_id" style="width:100%!important;">
                                                <option value="0">All Artist</option>
                                                @for ($i = 0; $i < count($artist); $i++) 
                                                <option value="{{ $artist[$i]['id'] }}">
                                                    {{ $artist[$i]['user_name'] }}
                                                </option>
                                                @endfor
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_category_drop">
                                        <div class="form-group">
                                            <label>Category<span class="text-danger">*</span></label>
                                            <select name="category_id" class="form-control" id="edit_category_id" style="width:100%!important;">
                                                <option value="0">All Category</option>
                                                @for ($i = 0; $i < count($category); $i++) 
                                                <option value="{{ $category[$i]['id'] }}">
                                                    {{ $category[$i]['name'] }}
                                                </option>
                                                @endfor
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_language_drop">
                                        <div class="form-group">
                                            <label>Language<span class="text-danger">*</span></label>
                                            <select name="language_id" class="form-control" id="edit_language_id" style="width:100%!important;">
                                                <option value="0">All Language</option>
                                                @for ($i = 0; $i < count($language); $i++) 
                                                <option value="{{ $language[$i]['id'] }}">
                                                    {{ $language[$i]['name'] }}
                                                </option>
                                                @endfor
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_no_of_content_drop">
                                        <div class="form-group">
                                            <label>No of Content<span class="text-danger">*</span></label>
                                            <input type="number" min="1" name="no_of_content" id="edit_no_of_content" class="form-control" placeholder="Enter Number Of Content">
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_order_by_upload_drop">
                                        <div class="form-group">
                                            <label>Order by Upload<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_upload" id="edit_order_by_upload_yes" class="custom-control-input" value="1" checked>
                                                    <label class="custom-control-label" for="edit_order_by_upload_yes">Asc</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_upload" id="edit_order_by_upload_no" class="custom-control-input" value="2">
                                                    <label class="custom-control-label" for="edit_order_by_upload_no">Desc</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_order_by_play_drop">
                                        <div class="form-group">
                                            <label>Order by Play<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_play" id="edit_order_by_play_yes" class="custom-control-input" value="1" checked>
                                                    <label class="custom-control-label" for="edit_order_by_play_yes">Asc</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="order_by_play" id="edit_order_by_play_no" class="custom-control-input" value="2">
                                                    <label class="custom-control-label" for="edit_order_by_play_no">Desc</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 edit_view_all_drop">
                                        <div class="form-group">
                                            <label>View All<span class="text-danger">*</span></label>
                                            <div class="radio-group">
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="view_all" id="edit_view_all_yes" class="custom-control-input" value="1" checked>
                                                    <label class="custom-control-label" for="edit_view_all_yes">Yes</label>
                                                </div>
                                                <div class="custom-control custom-radio">
                                                    <input type="radio" name="view_all" id="edit_view_all_no" class="custom-control-input" value="0">
                                                    <label class="custom-control-label" for="edit_view_all_no">No</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default mw-120" onclick="update_section()">Update</button>
                                <button type="button" class="btn btn-cancel mw-120" data-dismiss="modal">Close</button>
                                <input type="hidden" name="_method" value="PATCH">
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- sortableModal -->
            <div class="modal fade" id="sortableModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="sortableModalLabel" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title w-100 text-center" id="sortableModalLabel">Section Sortable List</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="close">
                                <span aria-hidden="true" class="text-dark">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div id="imageListId">
                                
                            </div>
                        </div>
                        <div class="modal-footer justify-content-center">
                            <form enctype="multipart/form-data" id="save_section_sortable">
                                @csrf
                                <input id="outputvalues" type="hidden" name="ids" value="" />
                                <div class="w-100 text-center">
                                    <button type="button" class="btn btn-default mw-120" onclick="save_section_sortable()">{{__('Label.SAVE')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        $("#language_id").select2();
        $("#artist_id").select2();
        $("#category_id").select2();
        $("#edit_language_id").select2({ dropdownParent: $('#exampleModal') });
        $("#edit_artist_id").select2({ dropdownParent: $('#exampleModal') });
        $("#edit_category_id").select2({ dropdownParent: $('#exampleModal') });

        $(".screen_layout_drop").hide();
        $(".artist_drop").hide();
        $(".category_drop").hide();
        $(".language_drop").hide();
        $(".no_of_content_drop").hide();
        $(".order_by_upload_drop").hide();
        $(".order_by_play_drop").hide();
        $(".view_all_drop").hide();

        var Tab = $("ul.tabs li a.active");
        var Is_home_screen = Tab.data("is_home_screen");
        var TopCategoryId = 0;
        $('.nav-item a').on('click', function() {
            Is_home_screen = $(this).data("is_home_screen");
            TopCategoryId = $(this).data("id");  
        });

        // Content_Type 
        $("#content_type").change(function() {

            var content_type = $(this).children("option:selected").val();
            if(content_type == 1 || content_type == 2){

                $(".artist_drop").show();
                if(Is_home_screen == 1){
                    $(".category_drop").show();
                } else {
                    $(".category_drop").hide();
                }
                $(".language_drop").show();
                $(".no_of_content_drop").show();
                $(".order_by_upload_drop").show();
                $(".order_by_play_drop").show();
                $(".view_all_drop").show();

                $(".screen_layout_drop").show();
                $("#screen_layout").children().removeAttr("selected");
                $("#screen_layout option[value='grid_view']").show();
                $("#screen_layout option[value='list_view']").show();
                $("#screen_layout option[value='portrait']").show();
                $("#screen_layout option[value='landscape']").show();
                $("#screen_layout option[value='small_square']").show();
                $("#screen_layout option[value='big_square']").show();
                $("#screen_layout option[value='details_square']").show();
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='round']").hide();

            } else if(content_type == 3){

                $(".artist_drop").hide();
                $(".category_drop").hide();
                $(".language_drop").hide();
                $(".no_of_content_drop").hide();
                $(".order_by_upload_drop").hide();
                $(".order_by_play_drop").hide();
                $(".view_all_drop").hide();

                $(".screen_layout_drop").show();
                $("#screen_layout").children().removeAttr("selected");
                $("#screen_layout option[value='grid_view']").hide();
                $("#screen_layout option[value='list_view']").hide();
                $("#screen_layout option[value='portrait']").hide();
                $("#screen_layout option[value='landscape']").hide();
                $("#screen_layout option[value='small_square']").hide();
                $("#screen_layout option[value='big_square']").hide();
                $("#screen_layout option[value='details_square']").hide();
                $("#screen_layout option[value='category']").show();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='round']").hide();

            } else if(content_type == 4){

                $(".artist_drop").hide();
                $(".category_drop").hide();
                $(".language_drop").hide();
                $(".no_of_content_drop").hide();
                $(".order_by_upload_drop").hide();
                $(".order_by_play_drop").hide();
                $(".view_all_drop").hide();

                $(".screen_layout_drop").show();
                $("#screen_layout").children().removeAttr("selected");
                $("#screen_layout option[value='grid_view']").hide();
                $("#screen_layout option[value='list_view']").hide();
                $("#screen_layout option[value='portrait']").hide();
                $("#screen_layout option[value='landscape']").hide();
                $("#screen_layout option[value='small_square']").hide();
                $("#screen_layout option[value='big_square']").hide();
                $("#screen_layout option[value='details_square']").hide();
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").show();
                $("#screen_layout option[value='round']").hide();

            } else if(content_type == 5){

                $(".artist_drop").hide();
                $(".category_drop").hide();
                $(".language_drop").hide();
                $(".no_of_content_drop").hide();
                $(".order_by_upload_drop").hide();
                $(".order_by_play_drop").hide();
                $(".view_all_drop").hide();

                $(".screen_layout_drop").show();
                $("#screen_layout").children().removeAttr("selected");
                $("#screen_layout option[value='grid_view']").hide();
                $("#screen_layout option[value='list_view']").hide();
                $("#screen_layout option[value='portrait']").hide();
                $("#screen_layout option[value='landscape']").hide();
                $("#screen_layout option[value='small_square']").hide();
                $("#screen_layout option[value='big_square']").hide();
                $("#screen_layout option[value='details_square']").hide();
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='round']").show();

            } else if(content_type == 6){

                $(".artist_drop").hide();
                $(".category_drop").hide();
                $(".language_drop").hide();
                $(".no_of_content_drop").hide();
                $(".order_by_upload_drop").hide();
                $(".order_by_play_drop").hide();
                $(".view_all_drop").hide();

                $(".screen_layout_drop").show();
                $("#screen_layout").children().removeAttr("selected");
                $("#screen_layout option[value='grid_view']").hide();
                $("#screen_layout option[value='list_view']").hide();
                $("#screen_layout option[value='portrait']").hide();
                $("#screen_layout option[value='landscape']").hide();
                $("#screen_layout option[value='small_square']").show();
                $("#screen_layout option[value='big_square']").hide();
                $("#screen_layout option[value='details_square']").hide();
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='round']").hide();
            } else {

                $(".artist_drop").hide();
                $(".category_drop").hide();
                $(".language_drop").hide();
                $(".no_of_content_drop").hide();
                $(".order_by_upload_drop").hide();
                $(".order_by_play_drop").hide();
                $(".view_all_drop").hide();
            }
        });

        // Save Section
        function save_section(){
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                var formData = new FormData($("#save_content_section")[0]);
                formData.append('is_home_screen', Is_home_screen);
                formData.append('top_category_id', TopCategoryId);

                $("#dvloader").show();
                $.ajax({
                    type:'POST',
                    url:'{{ route("sectionaudiobook.store") }}',
                    data:formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'save_content_section', '{{ route("sectionaudiobook.index") }}');
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

        // List Section
        if(Is_home_screen == 1) {
            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                type: 'POST',
                url: '{{ route("sectionaudiobook.content.data") }}',
                data: {
                    is_home_screen: Is_home_screen,
                    top_category_id: 0,
                },
                success: function(resp) {
                    $('.after-add-more').html('');
                    for (var i = 0; i < resp.result.length; i++) {

                        if (resp.result[i].content_type == 1) {
                            var content_type = "Audio Book";
                        } else if (resp.result[i].content_type == 2) {
                            var content_type = "Novel";
                        } else if (resp.result[i].content_type == 3) {
                            var content_type = "Category";
                        } else if (resp.result[i].content_type == 4) {
                            var content_type = "Language";
                        } else if (resp.result[i].content_type == 5) {
                            var content_type = "Artist";
                        } else if (resp.result[i].content_type == 6) {
                            var content_type = "Continue Playing";
                        } 

                        if (resp.result[i].screen_layout == "grid_view") {
                            var screen_layout = "Grid View";
                        } else if (resp.result[i].screen_layout == "list_view") {
                            var screen_layout = "List View";
                        } else if (resp.result[i].screen_layout == "portrait") {
                            var screen_layout = "Portrait";
                        } else if (resp.result[i].screen_layout == "landscape") {
                            var screen_layout = "Landscape";
                        } else if (resp.result[i].screen_layout == "small_square") {
                            var screen_layout = "Small Square";
                        } else if (resp.result[i].screen_layout == "big_square") {
                            var screen_layout = "Big Square";
                        } else if (resp.result[i].screen_layout == "details_square") {
                            var screen_layout = "Details Square";
                        } else if (resp.result[i].screen_layout == "category") {
                            var screen_layout = "Category";
                        } else if (resp.result[i].screen_layout == "language") {
                            var screen_layout = "Language";
                        } else if (resp.result[i].screen_layout == "round") {
                            var screen_layout = "Round";
                        }

                        var data = '<div class="card custom-border-card mt-3">'+
                                '<h5 class="card-header">Edit Section</h5>'+
                                '<div class="card-body">'+
                                    '<form id="edit_section_'+resp.result[i].id+'" enctype="multipart/form-data">'+
                                        '<input type="hidden" name="id" value="'+resp.result[i].id+'">'+
                                        '<div class="form-row">'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>{{__("Label.Title")}}</label>'+
                                                    '<input type="text" name="title" value="'+resp.result[i].title+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>Short Title</label>'+
                                                    '<input type="text" name="short_title" value="'+resp.result[i].short_title+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>Content Type</label>'+
                                                    '<input type="text" name="content_type" value="'+content_type+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>Screen Layout</label>'+
                                                    '<input type="text" name="screen_layout" value="'+screen_layout+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                        '</div>'+
                                        '<div class="border-top pt-3 text-right">'+
                                            '<button type="button" data-toggle="modal" data-target="#exampleModal" class="btn btn-default mw-120" onclick="edit_section('+resp.result[i].id+')">{{__("Label.UPDATE")}}</button>'+
                                            '<button type="button" class="btn btn-cancel mw-120 ml-2" onclick="delete_section('+resp.result[i].id+')">DELETE</button>'+
                                            '<input type="hidden" name="_method" value="PATCH">'+
                                        '</div>'+
                                    '</form>'+
                                '</div>'+
                            '</div>';

                        $('.after-add-more').append(data);
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
        function Top_Content(is_home_screen, top_category_id, category_type) {

            document.getElementById("save_content_section").reset();
            $("#language_id").val(0).trigger("change");
            $("#artist_id").val(0).trigger("change"); 
            $("#category_id").val(0).trigger("change"); 

            if(is_home_screen == 1){

                $(".artist_drop").hide();
                $(".category_drop").hide();
                $(".language_drop").hide();
                $(".no_of_content_drop").hide();
                $(".order_by_upload_drop").hide();
                $(".order_by_play_drop").hide();
                $(".view_all_drop").hide();
                $(".screen_layout_drop").hide();

                $(".content_type_drop").show();
                $("#content_type").children().removeAttr("selected");
                $("#content_type option[value='1']").show();
                $("#content_type option[value='2']").show();
                $("#content_type option[value='3']").show();
                $("#content_type option[value='4']").show();
                $("#content_type option[value='5']").show();
                $("#content_type option[value='6']").show();

            } else if(is_home_screen == 2){

                $(".artist_drop").show();
                $(".category_drop").hide();
                $(".language_drop").show();
                $(".no_of_content_drop").show();
                $(".order_by_upload_drop").show();
                $(".order_by_play_drop").show();
                $(".view_all_drop").show();

                $(".content_type_drop").show();
                $("#content_type").children().removeAttr("selected");
                $("#content_type option[value='1']").show();
                $("#content_type option[value='2']").show();
                $("#content_type option[value='3']").hide();
                $("#content_type option[value='4']").hide();
                $("#content_type option[value='5']").hide();
                $("#content_type option[value='6']").hide();

                $(".screen_layout_drop").show();
                $("#screen_layout").children().removeAttr("selected");
                $("#screen_layout option[value='grid_view']").show();
                $("#screen_layout option[value='list_view']").show();
                $("#screen_layout option[value='portrait']").show();
                $("#screen_layout option[value='landscape']").show();
                $("#screen_layout option[value='small_square']").show();
                $("#screen_layout option[value='big_square']").show();
                $("#screen_layout option[value='details_square']").show();
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='round']").hide();
            }

            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                type: 'POST',
                url: '{{ route("sectionaudiobook.content.data") }}',
                data: {
                    is_home_screen: is_home_screen,
                    top_category_id: top_category_id,
                },
                success: function(resp) {
                    $('.after-add-more').html('');
                    for (var i = 0; i < resp.result.length; i++) {

                        if (resp.result[i].content_type == 1) {
                            var content_type = "Audio Book";
                        } else if (resp.result[i].content_type == 2) {
                            var content_type = "Novel";
                        } else if (resp.result[i].content_type == 3) {
                            var content_type = "Category";
                        } else if (resp.result[i].content_type == 4) {
                            var content_type = "Language";
                        } else if (resp.result[i].content_type == 5) {
                            var content_type = "Artist";
                        } else if (resp.result[i].content_type == 6) {
                            var content_type = "Continue Playing";
                        } 

                        if (resp.result[i].screen_layout == "grid_view") {
                            var screen_layout = "Grid View";
                        } else if (resp.result[i].screen_layout == "list_view") {
                            var screen_layout = "List View";
                        } else if (resp.result[i].screen_layout == "portrait") {
                            var screen_layout = "Portrait";
                        } else if (resp.result[i].screen_layout == "landscape") {
                            var screen_layout = "Landscape";
                        } else if (resp.result[i].screen_layout == "small_square") {
                            var screen_layout = "Small Square";
                        } else if (resp.result[i].screen_layout == "big_square") {
                            var screen_layout = "Big Square";
                        } else if (resp.result[i].screen_layout == "details_square") {
                            var screen_layout = "Details Square";
                        } else if (resp.result[i].screen_layout == "category") {
                            var screen_layout = "Category";
                        } else if (resp.result[i].screen_layout == "language") {
                            var screen_layout = "Language";
                        } else if (resp.result[i].screen_layout == "round") {
                            var screen_layout = "Round";
                        }

                        var data = '<div class="card custom-border-card mt-3">'+
                                '<h5 class="card-header">Edit Section</h5>'+
                                '<div class="card-body">'+
                                    '<form id="edit_section_'+resp.result[i].id+'" enctype="multipart/form-data">'+
                                        '<input type="hidden" name="id" value="'+resp.result[i].id+'">'+
                                        '<div class="form-row">'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>{{__("Label.Title")}}</label>'+
                                                    '<input type="text" name="title" value="'+resp.result[i].title+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>Short Title</label>'+
                                                    '<input type="text" name="short_title" value="'+resp.result[i].short_title+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>Content Type</label>'+
                                                    '<input type="text" name="content_type" value="'+content_type+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                            '<div class="col-md-3">'+
                                                '<div class="form-group">'+
                                                    '<label>Screen Layout</label>'+
                                                    '<input type="text" name="screen_layout" value="'+screen_layout+'" class="form-control" readonly>'+
                                                '</div>'+
                                            '</div>'+
                                        '</div>'+
                                        '<div class="border-top pt-3 text-right">'+
                                            '<button type="button" data-toggle="modal" data-target="#exampleModal" class="btn btn-default mw-120" onclick="edit_section('+resp.result[i].id+')">{{__("Label.UPDATE")}}</button>'+
                                            '<button type="button" class="btn btn-cancel mw-120 ml-2" onclick="delete_section('+resp.result[i].id+')">DELETE</button>'+
                                            '<input type="hidden" name="_method" value="PATCH">'+
                                        '</div>'+
                                    '</form>'+
                                '</div>'+
                            '</div>';

                        $('.after-add-more').append(data);
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    toastr.error(errorThrown, textStatus);
                }
            });
        };

        // Update Section
        function edit_section(id){

            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                type: 'POST',
                url: '{{ route("sectionaudiobook.content.edit") }}',
                data: {
                    id: id,
                },
                success: function(resp) {

                    if(resp.result != null){

                        $("#edit_id").val(resp.result.id);
                        $("#edit_title").val(resp.result.title);
                        $("#edit_short_title").val(resp.result.short_title);
                        $("#edit_content_type").val(resp.result.content_type).attr("selected","selected");
                        $("#edit_screen_layout").val(resp.result.screen_layout).attr("selected","selected");
                        $('#edit_artist_id').val(resp.result.artist_id).trigger('change');
                        $('#edit_category_id').val(resp.result.category_id).trigger('change');
                        $('#edit_language_id').val(resp.result.language_id).trigger('change');
                        $("#edit_no_of_content").val(resp.result.no_of_content);
                        if(resp.result.order_by_upload == 1){
                            $("#edit_order_by_upload_yes").attr('checked','checked');
                        } else {
                            $("#edit_order_by_upload_no").attr('checked','checked');
                        }
                        if(resp.result.order_by_play == 1){
                            $("#edit_order_by_play_yes").attr('checked','checked');
                        } else {
                            $("#edit_order_by_play_no").attr('checked','checked');
                        }
                        if(resp.result.view_all == 1){
                            $("#edit_view_all_yes").attr('checked','checked');
                        } else {
                            $("#edit_view_all_no").attr('checked','checked');
                        }

                        // Content_Type
                        if(resp.result.is_home_screen == 1){

                            $(".edit_content_type_drop").show();
                            $(".edit_content_type_drop option[value='3']").show();
                            $(".edit_content_type_drop option[value='4']").show();
                            $(".edit_content_type_drop option[value='5']").show();
                            $(".edit_content_type_drop option[value='6']").show();
                        } else if(resp.result.is_home_screen == 2){

                            $(".edit_content_type_drop").show();
                            $(".edit_content_type_drop option[value='3']").hide();
                            $(".edit_content_type_drop option[value='4']").hide();
                            $(".edit_content_type_drop option[value='5']").hide();
                            $(".edit_content_type_drop option[value='6']").hide();
                        } else {
                            $(".edit_content_type_drop").hide();
                        }

                        if(resp.result.content_type == 1 || resp.result.content_type == 2){

                            $(".edit_artist_drop").show();
                            if(resp.result.is_home_screen == 1){
                                $(".edit_category_drop").show();
                            } else {
                                $(".edit_category_drop").hide();
                            }
                            $(".edit_language_drop").show();
                            $(".edit_no_of_content_drop").show();
                            $(".edit_order_by_upload_drop").show();
                            $(".edit_order_by_play_drop").show();
                            $(".edit_view_all_drop").show();

                            $(".edit_screen_layout_drop").show();
                            $("#edit_screen_layout option[value='grid_view']").show();
                            $("#edit_screen_layout option[value='list_view']").show();
                            $("#edit_screen_layout option[value='portrait']").show();
                            $("#edit_screen_layout option[value='landscape']").show();
                            $("#edit_screen_layout option[value='small_square']").show();
                            $("#edit_screen_layout option[value='big_square']").show();
                            $("#edit_screen_layout option[value='details_square']").show();
                            $("#edit_screen_layout option[value='category']").hide();
                            $("#edit_screen_layout option[value='language']").hide();
                            $("#edit_screen_layout option[value='round']").hide();
                        } else {

                            $(".edit_artist_drop").hide();
                            $(".edit_category_drop").hide();
                            $(".edit_language_drop").hide();
                            $(".edit_no_of_content_drop").hide();
                            $(".edit_order_by_upload_drop").hide();
                            $(".edit_order_by_play_drop").hide();
                            $(".edit_view_all_drop").hide();

                            if(resp.result.content_type == 3){

                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").hide();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").show();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").hide();
                            } else if(resp.result.content_type == 4){

                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").hide();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").show();
                                $("#edit_screen_layout option[value='round']").hide();
                            } else if(resp.result.content_type == 5){

                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").hide();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").show();
                            } else if(resp.result.content_type == 6){

                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").show();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").hide();
                            } else {
                                $(".edit_screen_layout_drop").hide();
                            }
                        }

                        $("#edit_content_type").change(function() {
                            
                            var content_type = $(this).children("option:selected").val();
                            if(content_type == 1 || content_type == 2){
    
                                $(".edit_artist_drop").show();
                                if(resp.result.is_home_screen == 1){
                                    $(".edit_category_drop").show();
                                } else {
                                    $(".edit_category_drop").hide();
                                }
                                $(".edit_language_drop").show();
                                $(".edit_no_of_content_drop").show();
                                $(".edit_order_by_upload_drop").show();
                                $(".edit_order_by_play_drop").show();
                                $(".edit_view_all_drop").show();
    
                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout").children().removeAttr("selected");
                                $("#edit_screen_layout option[value='grid_view']").show();
                                $("#edit_screen_layout option[value='list_view']").show();
                                $("#edit_screen_layout option[value='portrait']").show();
                                $("#edit_screen_layout option[value='landscape']").show();
                                $("#edit_screen_layout option[value='small_square']").show();
                                $("#edit_screen_layout option[value='big_square']").show();
                                $("#edit_screen_layout option[value='details_square']").show();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").hide();

                            } else if(content_type == 3){
    
                                $(".edit_artist_drop").hide();
                                $(".edit_category_drop").hide();
                                $(".edit_language_drop").hide();
                                $(".edit_no_of_content_drop").hide();
                                $(".edit_order_by_upload_drop").hide();
                                $(".edit_order_by_play_drop").hide();
                                $(".edit_view_all_drop").hide();
    
                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout").children().removeAttr("selected");
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").hide();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").show();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").hide();
    
                            } else if(content_type == 4){
    
                                $(".edit_artist_drop").hide();
                                $(".edit_category_drop").hide();
                                $(".edit_language_drop").hide();
                                $(".edit_no_of_content_drop").hide();
                                $(".edit_order_by_upload_drop").hide();
                                $(".edit_order_by_play_drop").hide();
                                $(".edit_view_all_drop").hide();
    
                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout").children().removeAttr("selected");
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").hide();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").show();
                                $("#edit_screen_layout option[value='round']").hide();
    
                            } else if(content_type == 5){
    
                                $(".edit_artist_drop").hide();
                                $(".edit_category_drop").hide();
                                $(".edit_language_drop").hide();
                                $(".edit_no_of_content_drop").hide();
                                $(".edit_order_by_upload_drop").hide();
                                $(".edit_order_by_play_drop").hide();
                                $(".edit_view_all_drop").hide();
    
                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout").children().removeAttr("selected");
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").hide();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").show();
    
                            } else if(content_type == 6){
    
                                $(".edit_artist_drop").hide();
                                $(".edit_category_drop").hide();
                                $(".edit_language_drop").hide();
                                $(".edit_no_of_content_drop").hide();
                                $(".edit_order_by_upload_drop").hide();
                                $(".edit_order_by_play_drop").hide();
                                $(".edit_view_all_drop").hide();
    
                                $(".edit_screen_layout_drop").show();
                                $("#edit_screen_layout").children().removeAttr("selected");
                                $("#edit_screen_layout option[value='grid_view']").hide();
                                $("#edit_screen_layout option[value='list_view']").hide();
                                $("#edit_screen_layout option[value='portrait']").hide();
                                $("#edit_screen_layout option[value='landscape']").hide();
                                $("#edit_screen_layout option[value='small_square']").show();
                                $("#edit_screen_layout option[value='big_square']").hide();
                                $("#edit_screen_layout option[value='details_square']").hide();
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='round']").hide();
                            } else {
    
                                $(".edit_artist_drop").hide();
                                $(".edit_category_drop").hide();
                                $(".edit_language_drop").hide();
                                $(".edit_no_of_content_drop").hide();
                                $(".edit_order_by_upload_drop").hide();
                                $(".edit_order_by_play_drop").hide();
                                $(".edit_view_all_drop").hide();
                                $(".edit_screen_layout_drop").hide();
                            }
                        });
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
        function update_section(){

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var id = $('#edit_id').val();
                var formData = new FormData($("#edit_content_section")[0]);

                var url = '{{ route("sectionaudiobook.update", ":id") }}';
                    url = url.replace(':id', id);

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
                            $('#exampleModal').modal('toggle');
                        }
                        get_responce_message(resp, 'edit_content_section', '{{ route("sectionaudiobook.index") }}');
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

        // Delete Section
        function delete_section(id){

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                var result = confirm("Are you sure !!! You want to Delete this Section ?");
                if(result){

                    $("#dvloader").show();
    
                    var url = '{{ route("sectionaudiobook.show", ":id") }}';
                        url = url.replace(':id', id);
    
                    $.ajax({
                        headers: {
                            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                        },
                        type: 'GET',
                        url: url,
                        cache: false,
                        contentType: false,
                        processData: false,
                        success: function(resp) {
                            $("#dvloader").hide();
                            get_responce_message(resp, '', '{{ route("sectionaudiobook.index") }}');
                        },
                        error: function(XMLHttpRequest, textStatus, errorThrown) {
                            $("#dvloader").hide();
                            toastr.error(errorThrown, textStatus);
                        }
                    });
                }
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        }

        // Sortable Section
        $("#imageListId").sortable({
            update: function(event, ui) {
                getIdsOfImages();
            } //end update
        });

        function getIdsOfImages() {
            var values = [];
            $('.listitemClass').each(function(index) {
                values.push($(this).attr("id")
                    .replace("imageNo", ""));
            });
            $('#outputvalues').val(values);
        }
        function sortableBTN(){
            var Tab = $("ul.tabs li a.active");
            var Is_home_screen = Tab.data("is_home_screen");
            var TopCategoryId = Tab.data("id");

            $("#dvloader").show();
            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                type: 'POST',
                url: '{{ route("sectionaudiobook.content.sortable") }}',
                data: {
                    is_home_screen: Is_home_screen,
                    top_category_id: TopCategoryId,
                },
                success: function(resp) {
                    $("#dvloader").hide();

                    $('#imageListId').html('');
                    for (var i = 0; i < resp.result.length; i++) {

                        var data = '<div id="'+ resp.result[i].id+'" class="listitemClass mb-2" style="background-color: #e9ecef;border: 1px solid black;cursor: s-resize;">'+
                                    '<p class="m-2">'+resp.result[i].title+'</p>'+
                                '</div>';

                        $('#imageListId').append(data);
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
        function save_section_sortable() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){
                $("#dvloader").show();
                var formData = new FormData($("#save_section_sortable")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("sectionaudiobook.content.sortable.save") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'save_section_sortable', '{{ route("sectionaudiobook.index") }}');
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