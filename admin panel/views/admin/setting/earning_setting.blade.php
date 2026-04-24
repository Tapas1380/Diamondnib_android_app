@extends('admin.layout.page-app')
@section('page_title', 'Earning Setting')

@section('content')
    @include('admin.layout.sidebar')       
        
    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('Label.Earning Setting')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Earning Setting</li>
                    </ol>
                </div>
            </div>

            <ul class="nav nav-pills custom-tabs" id="pills-tab" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="daily-login-point-tab" data-toggle="pill" href="#daily-login-point" role="tab" aria-controls="daily-login-point" aria-selected="false">DAILY LOGIN POINT</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="spin-wheel-point-tab" data-toggle="pill" href="#spin-wheel-point" role="tab" aria-controls="spin-wheel-point" aria-selected="true">SPIN WHEEL POINT</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="get-free-cong-point-tab" data-toggle="pill" href="#get-free-cong-point" role="tab" aria-controls="get-free-cong-point" aria-selected="false">GET FREE COIN POINT</a>
                </li>
            </ul>

            <div class="tab-content" id="pills-tabContent">
                <div class="tab-pane fade show active" id="daily-login-point" role="tabpanel" aria-labelledby="daily-login-point-tab">
                    <div class="card custom-border-card mt-3">
                        <h5 class="card-header">Daily Login Point</h5>
                        <div class="card-body">
                            <form id="daily_login" enctype="multipart/form-data">
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                <table class="table table-bordered table-striped text-center">
                                    <thead>
                                        <tr style="background: #F9FAFF;">
                                            <th width="50%">Activity Name</th>
                                            <th>Point</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Day-1</td>
                                            <td><input type="number" name="Day-1" class="form-control" min="0" value="{{$reward_coin['Day-1']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>Day-2</td>
                                            <td><input type="number" name="Day-2" class="form-control" min="0" value="{{$reward_coin['Day-2']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>Day-3</td>
                                            <td><input type="number" name="Day-3" class="form-control" min="0" value="{{$reward_coin['Day-3']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>Day-4</td>
                                            <td><input type="number" name="Day-4" class="form-control" min="0" value="{{$reward_coin['Day-4']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>Day-5</td>
                                            <td><input type="number" name="Day-5" class="form-control" min="0" value="{{$reward_coin['Day-5']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>Day-6</td>
                                            <td><input type="number" name="Day-6" class="form-control" min="0" value="{{$reward_coin['Day-6']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>Day-7</td>
                                            <td><input type="number" name="Day-7" class="form-control" min="0" value="{{$reward_coin['Day-7']}}"></td>
                                        </tr>
                                    </tbody>
                                </table>
                                <br><br>
                                <div class="border-top pt-3 text-right">
                                    <button type="button" class="btn btn-default mw-120" onclick="daily_login()">{{__('Label.SAVE')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade" id="spin-wheel-point" role="tabpanel" aria-labelledby="spin-wheel-point-tab">
                    <div class="card custom-border-card">
                        <h5 class="card-header">Spin Wheel Point</h5>
                        <div class="card-body">
                            <form id="spin_wheel_point">
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                <table class="table table-bordered table-striped text-center">
                                    <thead>
                                        <tr style="background: #F9FAFF;">
                                            <th width="50%">Activity Name</th>
                                            <th>Point</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td><input type="number" name="1" class="form-control" min="0" value="{{$reward_coin['1']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td><input type="number" name="2" class="form-control" min="0" value="{{$reward_coin['2']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td><input type="number" name="3" class="form-control" min="0" value="{{$reward_coin['3']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>4</td>
                                            <td><input type="number" name="4" class="form-control" min="0" value="{{$reward_coin['4']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>5</td>
                                            <td><input type="number" name="5" class="form-control" min="0" value="{{$reward_coin['5']}}"></td>
                                        </tr>
                                        <tr>
                                            <td>6</td>
                                            <td><input type="number" name="6" class="form-control" min="0" value="{{$reward_coin['6']}}"></td>
                                        </tr>
                                    </tbody>
                                </table>
                                <br><br>
                                <div class="border-top pt-3 text-right">
                                    <button type="button" class="btn btn-default mw-120" onclick="spin_wheel_point()">{{__('Label.SAVE')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade" id="get-free-cong-point" role="tabpanel" aria-labelledby="get-free-cong-point-tab">
                    <div class="card custom-border-card mt-3">
                        <h5 class="card-header">Get Free Coin Point</h5>
                        <div class="card-body">
                            <form id="get_free_coin" enctype="multipart/form-data">
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                <table class="table table-bordered table-striped text-center">
                                    <thead>
                                        <tr style="background: #F9FAFF;">
                                            <th width="50%">Activity Name</th>
                                            <th>Point</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Free-coin</td>
                                            <td><input type="number" name="free-coin" class="form-control" min="0" value="{{$reward_coin['free-coin']}}"></td>
                                        </tr>
                                    </tbody>
                                </table>
                                <br><br>
                                <div class="border-top pt-3 text-right">
                                    <button type="button" class="btn btn-default mw-120" onclick="get_free_coin()">{{__('Label.SAVE')}}</button>
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

        // Sidebar Scroll Down
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

        function daily_login() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#daily_login")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("dailyloginpoint") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        $("html, body").animate({ scrollTop: 0 }, "swing");
                        get_responce_message(resp);
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
        function spin_wheel_point() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#spin_wheel_point")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("spinwheelpoint") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        $("html, body").animate({ scrollTop: 0 }, "swing");
                        get_responce_message(resp);
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
        function get_free_coin() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#get_free_coin")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("getfreecongpoint") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        $("html, body").animate({ scrollTop: 0 }, "swing");
                        get_responce_message(resp);
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