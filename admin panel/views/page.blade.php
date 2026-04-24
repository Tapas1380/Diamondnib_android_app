<html lang="en">

    <head>
        <meta charset="utf-8">
        <title>{{ $result->title }} || {{ app_name() }}</title>

        <style type="text/css">
            :root {
                --title-color: {{$settings['page_title_color']}};
                --background-color: {{$settings['page_background_color']}};
            }
            body {
                background-color: var(--background-color);
                margin: 0px;
            }
            .page-title{
                text-align: center;
                margin: 15px;
                font-size: 36px;
                color: var(--title-color);
                border-bottom: 2px solid var(--title-color);
            }
            .description{
                margin: 15px;
            }
        </style>
    </head>

    <body>

        <p class="page-title">{{ $result->title }}</p>

        <div class="description">
            <?php echo htmlspecialchars_decode($result->description); ?>
        </div>
        
    </body>

</html>