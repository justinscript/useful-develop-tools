
#!/bin/bash                                                                                                                                                                            
                                                                                                                                                        
function doGongji
{
        while(true)                                                                                                                                                                        
                do     
                    sleep 20
                    /usr/local/bin/webbench -c 19000 -t 30 http://www.autostreets.com/no-haggle?city=%E4%B8%8A%E6%B5%B7%E5%B8%82&age=2&pageNumber=2
                    if [ $? -eq 0  ]; then
                        doGongji
                    
                    fi
                
                done                                                                                                                                                                                                           }

doGongji
