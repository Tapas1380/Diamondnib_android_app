@extends('admin.layout.page-app')
@section('page_title', 'System Settings')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">

            <!-- mobile title -->
            <h1 class="page-title-sm">App Settings</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">System Settings</li>
                    </ol>
                </div>
            </div>

            <div class="row">
                <div class="col-6">
                    <div class="card custom-border-card">
                        <a data-bs-toggle="collapse" data-bs-target="#clear_data">
                            <h5 class="card-header"><i class="fa-solid fa-chevron-down float-right"></i>Clear Cache</h5>
                        </a>

                        <div id="clear_data" class="collapse">
                            <div class="card-body">
                                <p>This means that the extra uploaded files, images and videos in your system will be deleted.</p>
                                <div class="d-flex justify-content-end">
                                    <button type="button" class="btn btn-default mw-120" onclick="clear_data()">Clear Cache</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card custom-border-card">
                        <a data-bs-toggle="collapse" data-bs-target="#download_database">
                            <h5 class="card-header"><i class="fa-solid fa-chevron-down float-right"></i>Backup Database</h5>
                        </a>

                        <div id="download_database" class="collapse">
                            <div class="card-body">
                                <p>Download the SQL file of the current database.</p>
                                <div class="d-flex justify-content-end">
                                    <a href="{{ route('system.setting.downloadsqlfile') }}" onclick="return confirm('You want to download this SQL file ?')" class="btn btn-default mw-120">Download</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-6">
                    <div class="card custom-border-card">
                        <a data-bs-toggle="collapse" data-bs-target="#clean_database">
                            <h5 class="card-header"><i class="fa-solid fa-chevron-down float-right"></i>Clean Database</h5>
                        </a>

                        <div id="clean_database" class="collapse">
                            <div class="card-body">
                                <p>Dalete all data in database.</p>
                                <div class="d-flex justify-content-end">
                                    <button type="button" class="btn btn-default mw-120" onclick="clean_database()">Clean Database</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>

        // Sidebar Scroll Down
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

        function clear_data() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                if (confirm('Do you confirm Clear the Data !!!')) {

                    $("#dvloader").show();
                    $.ajax({
                        headers: {
                            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                        },
                        enctype: 'multipart/form-data',
                        type: 'POST',
                        url: '{{ route("system.setting.cleardata") }}',
                        cache: false,
                        contentType: false,
                        processData: false,
                        success: function(resp) {
                            $("#dvloader").hide();
                            get_responce_message(resp, '', '{{ route("system.setting.index") }}');
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
        function clean_database() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                if (confirm('Do you confirm Clean the Database !!!')) {

                    $("#dvloader").show();
                    $.ajax({
                        headers: {
                            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                        },
                        enctype: 'multipart/form-data',
                        type: 'POST',
                        url: '{{ route("system.setting.cleandatabase") }}',
                        cache: false,
                        contentType: false,
                        processData: false,
                        success: function(resp) {
                            $("#dvloader").hide();
                            get_responce_message(resp, '', '{{ route("system.setting.index") }}');
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
    </script>
@endsection