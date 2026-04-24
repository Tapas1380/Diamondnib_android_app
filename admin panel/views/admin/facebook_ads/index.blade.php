@extends('admin.layout.page-app')
@section('page_title', 'FaceBook Ads Settings')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">FaceBook Ads Settings</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">FaceBook Ads Settings</li>
                    </ol>
                </div>
            </div>

            <div class="card custom-border-card mt-3">
                <h5 class="card-header">FaceBook Ads {{__('Label.Android Settings')}}</h5>
                <div class="card-body">
                    <form id="fbad">
                        @csrf
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label for="fb_native_status">{{__('Label.Native Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_native_status" name="fb_native_status" class="custom-control-input" {{ ($result['fb_native_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_native_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_native_status1" name="fb_native_status" class="custom-control-input" {{ ($result['fb_native_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_native_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label for="fb_banner_status">{{__('Label.Banner Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_banner_status" name="fb_banner_status" class="custom-control-input" {{($result['fb_banner_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_banner_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_banner_status1" name="fb_banner_status" class="custom-control-input" {{ ($result['fb_banner_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_banner_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label for="fb_interstiatial_status">{{__('Label.Interstiatial Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_interstiatial_status" name="fb_interstiatial_status" class="custom-control-input" {{($result['fb_interstiatial_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_interstiatial_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_interstiatial_status1" name="fb_interstiatial_status" class="custom-control-input" {{ ($result['fb_interstiatial_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_interstiatial_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Native Key')}}</label>
                                    <input type="text" name="fb_native_id" class="form-control" value="{{$result['fb_native_id']}}" placeholder="Enter Native Key">
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Banner Key')}}</label>
                                    <input type="text" name="fb_banner_id" class="form-control" value="{{$result['fb_banner_id']}}" placeholder="Enter Banner key">
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Interstiatial Key')}}</label>
                                    <input type="text" name="fb_interstiatial_id" class="form-control" value="{{$result['fb_interstiatial_id']}}" placeholder="Enter Interstiatial Key">
                                </div>
                            </div>
                        </div>
                        <hr>
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group col-lg-6">
                                    <label for="fb_rewardvideo_status">{{__('Label.RewardVideo Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_rewardvideo_status" name="fb_rewardvideo_status" class="custom-control-input" {{($result['fb_rewardvideo_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_rewardvideo_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_rewardvideo_status1" name="fb_rewardvideo_status" class="custom-control-input" {{ ($result['fb_rewardvideo_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_rewardvideo_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group col-lg-6">
                                    <label for="fb_native_full_status">{{__('Label.Native Full Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_native_full_status" name="fb_native_full_status" class="custom-control-input" {{($result['fb_native_full_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_native_full_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_native_full_status1" name="fb_native_full_status" class="custom-control-input" {{ ($result['fb_native_full_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_native_full_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Rewardvideo Status Key')}}</label>
                                    <input type="text" name="fb_rewardvideo_id" class="form-control" value="{{$result['fb_rewardvideo_id']}}" placeholder="Enter Reward Video Status Key">
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Native Full Key')}}</label>
                                    <input type="text" name="fb_native_full_id" class="form-control" value="{{$result['fb_native_full_id']}}" placeholder="Enter Native Full Key">
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="fbad()">{{__('Label.SAVE')}}</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card custom-border-card mt-3">
                <h5 class="card-header">FaceBook Ads {{__('Label.IOS Settings')}}</h5>
                <div class="card-body">
                    <form id="fbad_ios">
                        @csrf
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label for="fb_ios_native_status">{{__('Label.Native Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_native_status" name="fb_ios_native_status" class="custom-control-input" {{ ($result['fb_ios_native_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_ios_native_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_native_status1" name="fb_ios_native_status" class="custom-control-input" {{ ($result['fb_ios_native_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_ios_native_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label for="fb_ios_banner_status">{{__('Label.Banner Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_banner_status" name="fb_ios_banner_status" class="custom-control-input" {{($result['fb_ios_banner_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_ios_banner_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_banner_status1" name="fb_ios_banner_status" class="custom-control-input" {{ ($result['fb_ios_banner_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_ios_banner_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label for="fb_ios_interstiatial_status">{{__('Label.Interstiatial Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_interstiatial_status" name="fb_ios_interstiatial_status" class="custom-control-input" {{($result['fb_ios_interstiatial_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_ios_interstiatial_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_interstiatial_status1" name="fb_ios_interstiatial_status" class="custom-control-input" {{ ($result['fb_ios_interstiatial_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_ios_interstiatial_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Native Key')}}</label>
                                    <input type="text" name="fb_ios_native_id" class="form-control" value="{{$result['fb_ios_native_id']}}" placeholder="Enter Native Key">
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Banner Key')}}</label>
                                    <input type="text" name="fb_ios_banner_id" class="form-control" value="{{$result['fb_ios_banner_id']}}" placeholder="Enter Banner Key">
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Interstiatial Key')}}</label>
                                    <input type="text" name="fb_ios_interstiatial_id" class="form-control" value="{{$result['fb_ios_interstiatial_id']}}" placeholder="Enter Interstiatial Key">
                                </div>
                            </div>
                        </div>
                        <hr>
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group col-lg-6">
                                    <label for="fb_ios_rewardvideo_status">{{__('Label.RewardVideo Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_rewardvideo_status" name="fb_ios_rewardvideo_status" class="custom-control-input" {{($result['fb_ios_rewardvideo_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_ios_rewardvideo_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_rewardvideo_status1" name="fb_ios_rewardvideo_status" class="custom-control-input" {{ ($result['fb_ios_rewardvideo_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_ios_rewardvideo_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group col-lg-6">
                                    <label for="fb_ios_native_full_status">{{__('Label.Native Full Status')}}</label>
                                    <div class="radio-group">
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_native_full_status" name="fb_ios_native_full_status" class="custom-control-input" {{($result['fb_ios_native_full_status']=='1')? "checked" : "" }} value="1">
                                            <label class="custom-control-label" for="fb_ios_native_full_status">{{__('Label.Yes')}}</label>
                                        </div>
                                        <div class="custom-control custom-radio">
                                            <input type="radio" id="fb_ios_native_full_status1" name="fb_ios_native_full_status" class="custom-control-input" {{ ($result['fb_ios_native_full_status']=='0')? "checked" : "" }} value="0">
                                            <label class="custom-control-label" for="fb_ios_native_full_status1">{{__('Label.No')}}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Rewardvideo Status Key')}}</label>
                                    <input type="text" name="fb_ios_rewardvideo_id" class="form-control" value="{{$result['fb_ios_rewardvideo_id']}}" placeholder="Enter Reward Video Status Key">
                                </div>
                            </div>
                            <div class="col-12 col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label>{{__('Label.Native Full Key')}}</label>
                                    <input type="text" name="fb_ios_native_full_id" class="form-control" value="{{$result['fb_ios_native_full_id']}}" placeholder="Enter native Full Key">
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="fbad_ios()">{{__('Label.SAVE')}}</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        function fbad() {
            var formData = new FormData($("#fbad")[0]);
            $("#dvloader").show();
            $.ajax({
                type: 'POST',
                url: '{{ route("fbads.android") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({scrollTop: 0}, "swing");
                    get_responce_message(resp);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
        function fbad_ios() {
            var formData = new FormData($("#fbad_ios")[0]);
            $("#dvloader").show();
            $.ajax({
                type: 'POST',
                url: '{{ route("fbads.ios") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({scrollTop: 0}, "swing");
                    get_responce_message(resp);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
    </script>
@endsection