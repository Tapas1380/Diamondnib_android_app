<!DOCTYPE html>
<html lang="en">

<head>

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js"></script>
    <style type="text/css">
        body {
            background-color: #f7f6ff;
        }

        svg {
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -300px;
            margin-left: -600px;
        }

        .message-box {
            height: 200px;
            width: 380px;
            position: absolute;
            top: 50%;
            left: 45%;
            margin-top: -175px;
            margin-left: 10px;
            color: #FFF;
            font-family: Roboto;
            font-weight: 300;
        }

        .message-box h1 {
            color: #4e45b8;
            font-size: 200px;
            line-height: 50px;
            margin-bottom: 40px;
        }

        .message-box p {
            color: #4e45b8;
            font-size: 50px;
            line-height: 50px;
            margin-bottom: 40px;
            margin-top: 60px;
            margin-left: -16px;
            word-spacing: 5px;
        }

        #Polygon-1,
        #Polygon-2,
        #Polygon-3,
        #Polygon-4,
        #Polygon-4,
        #Polygon-5 {
            animation: float 1s infinite ease-in-out alternate;
        }

        #Polygon-2 {
            animation-delay: .2s;
        }

        #Polygon-3 {
            animation-delay: .4s;
        }

        #Polygon-4 {
            animation-delay: .6s;
        }

        #Polygon-5 {
            animation-delay: .8s;
        }

        .btn-default {
            background: #4e45b8;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            color: #fff;
            border: 1px solid transparent;
            -webkit-transition: all 0.3s;
            transition: all 0.3s;
            padding: 8px 20px;
            text-align: center;
            margin-left: 80px;
            word-spacing: 5px;
        }

        .btn-default:hover {
            color: #4e45b8;
            background: transparent;
            border-color: #4e45b8;
        }

        @keyframes float {
            100% {
                transform: translateY(20px);
            }
        }

        @media (max-width: 450px) {
            .message-box {
                top: 50%;
                left: 50%;
                margin-top: -100px;
                margin-left: -190px;
                text-align: center;
            }

        }
    </style>
</head>

<body>
    <svg width="380px" height="500px" viewBox="0 0 837 1045">
        <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" sketch:type="MSPage">
            <path d="M353,9 L626.664028,170 L626.664028,487 L353,642 L79.3359724,487 L79.3359724,170 L353,9 Z" id="Polygon-1" stroke="#007FB2" stroke-width="6" sketch:type="MSShapeGroup"></path>
            <path d="M78.5,529 L147,569.186414 L147,648.311216 L78.5,687 L10,648.311216 L10,569.186414 L78.5,529 Z" id="Polygon-2" stroke="#EF4A5B" stroke-width="6" sketch:type="MSShapeGroup"></path>
            <path d="M773,186 L827,217.538705 L827,279.636651 L773,310 L719,279.636651 L719,217.538705 L773,186 Z" id="Polygon-3" stroke="#795D9C" stroke-width="6" sketch:type="MSShapeGroup"></path>
            <path d="M639,529 L773,607.846761 L773,763.091627 L639,839 L505,763.091627 L505,607.846761 L639,529 Z" id="Polygon-4" stroke="#F2773F" stroke-width="6" sketch:type="MSShapeGroup"></path>
            <path d="M281,801 L383,861.025276 L383,979.21169 L281,1037 L179,979.21169 L179,861.025276 L281,801 Z" id="Polygon-5" stroke="#36B455" stroke-width="6" sketch:type="MSShapeGroup"></path>
        </g>
    </svg>

    <div class="message-box">
        <h1 class="">404</h1>
        <p class="">Page Not Found</p>
    </div>

</body>

</html>