@extends('installation.layout.page-app')

@section('content')
    <div class="row">
        <div class="col-md-12 col-lg-12 col-xl-6 d-flex flex-column justify-content-center">
            <div class="install-card">

                <!-- Alert MSG -->
                @if(session()->has('error'))
                    <div class="alert alert-danger alert-block">
                        <button type="button" class="close" data-dismiss="alert" title="Remove">X</button>
                        <strong>{{ Session::get('error') }}</strong>
                    </div>
                @elseif(session()->has('success'))
                    <div class="alert alert-danger alert-block">
                        <button type="button" class="close" data-dismiss="alert" title="Remove">X</button>
                        <strong>{{ Session::get('success') }}</strong>
                    </div>
                @endif

                <h1 class="primary-color install-title">{{__('Label.purchase_information')}}</h1>
                <h1 class="install_sub_title mb-2">{{__('Label.provide_your_codecanyon_username_&purchase_code')}}</h1>
                <h6>{{__('Label.to_find_your_purchase_code_you_can_visit_this_link')}}
                    <a href="https://help.market.envato.com/hc/en-us/articles/202822600-Where-Is-My-Purchase-Code" target="_blank">{{__('Label.where_is_my_purchase_code')}}</a>
                </h6>

                <div class="mt-3">
                    <form method="POST" action="{{ route('purchase_code',['token'=>bcrypt('step_3')]) }}" onsubmit="showLoder()">
                        @csrf
                        <div class="form-row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>{{__('Label.user_name')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="user_name" value="{{ $user_name }}" class="form-control" placeholder="{{__('Label.user_name_here')}}" autofocus>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>{{__('Label.purchase_code')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="purchase_code" value="{{ $purchase_code }}" class="form-control" placeholder="{{__('Label.purchase_code_here')}}">
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-install">{{__('Label.continue')}}<i class="fa-solid fa-angles-right ml-2"></i></button>
                    </form>
                </div>

                @if(session()->has('result'))
                    <div class="card mt-4">
                        <div class="card-body">
                            <div class="mar-ver pad-btm text-center">
                                <h6>{{__('Label.this_purchase_code_is_already_registered_to_a_different_domain')}}</h6>
                                <h5 class="primary-color"><b>{{ session('result') }}</b></h5>
                            </div>
                            <div class="text-center mt-3">
                                <a href="{{ route('update_purchase_code') }}" class="btn btn-install" onclick="showLoader()">{{__('Label.yes') }}</a>
                                <a href="{{ route('step2', ['token' => bcrypt('step_2')]) }}" class="btn btn-install-cancel" onclick="showLoader()">{{__('Label.no') }}</a>
                            </div>
                        </div>
                    </div>
                @endif

                <!-- Footer -->
                @include('installation.layout.footer')

            </div>
        </div>
        <div class="col-lg-6 install-bg-img d-none d-lg-block">
            <img src="{{ asset('assets/imgs/install_bg.png') }}" alt="Software Installation">
        </div>
    </div>
@endsection