if(en) begin
             //When money is input
            if(Five_in || Ten_in || Twenty_in)begin   
                case(current_state) 
                    S0:
                        if(Five_in) begin
                            next_state = S5;
                            amount_in_next = 5;
                        end
                        else if(Ten_in) begin
                            next_state = S10;
                            amount_in_next = 10;
                        end
                        else if(Twenty_in) begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                        else begin
                            next_state = S0;
                            amount_in_next = 0;
                        end
                    S5:
                        if(Five_in) begin
                            next_state = S10;
                            amount_in_next = 10;
                        end
                        else if(Ten_in) begin
                            next_state = S15;
                            amount_in_next = 15;
                        end
                        else if(Twenty_in) begin
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else begin
                            next_state = S5;
                            amount_in_next = 5;
                        end
                    S10:
                        if(Five_in) begin
                            amount_in_next = 15;
                            next_state = S15;
                        end
                        else if(Ten_in) begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                        else if(Twenty_in) begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                        else begin
                            amount_in_next = 10;
                            next_state = S10;
                        end
                    S15:
                        if(Five_in) begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                        else if(Ten_in) begin
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else if(Twenty_in) begin
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else begin
                            next_state = S15;
                            amount_in_next = 15;
                        end
                    S20:
                        if(Five_in) begin
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else if(Ten_in) begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                        else if(Twenty_in) begin
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                    //Until here its regular state change only
                    //After here there will be overflow conditions also therfore we need to handle it
                    //When overflow condition is reached (i.e money in system > 40)
                    //Enable signal to the overflow block is 1 and stste remains the same

                    S25:
                        if(Five_in) begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                        else if(Ten_in) begin
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else if(Twenty_in) begin
                            en_for_overflow_next = 1;
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else begin
                            next_state = S25;
                            amount_in_next = 25;
                        end

                    S30:
                        if(Five_in) begin
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else if(Ten_in) begin
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else if(Twenty_in)begin
                            next_state = S30;
                            amount_in_next = 30;
                            en_for_overflow_next = 1;
                        end
                        else begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                    S35:
                        if(Five_in) begin
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else if(Ten_in) begin
                            en_for_overflow_next = 1;
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else if(Twenty_in)begin
                            en_for_overflow_next = 1;
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else  begin
                            next_state = S35;
                            amount_in_next = 35;
                            en_for_overflow_next = 0;
                        end
                    S40:
                        if(Five_in | Ten_in | Twenty_in) begin
                            en_for_overflow_next = 1;
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else begin
                            next_state = S40;
                            amount_in_next = 40;
                            en_for_overflow_next = 0;
                        end
                    default:
                        en_for_overflow_next = 0;
                        next_state = S0;
                        amount_in_next = 0;
                        
                    endcase
            end

            //To enable the respective items module after user inputs item needed
            //And also determine the req_amount which goes to the return change block
            case(select_item)
                default:
                    req_amt = 0;
                    en_for_item1_next = 0;
                    en_for_item2_next = 0;
                    en_for_item3_next = 0;
                2'd1:
                    if (amount_in_next - cost_It_1 >= 0) begin
                        req_amt = amount_in_next - cost_It_1; 
                        en_for_item1_next = 1;
                    end
                        else begin
                        en_for_item1_next = 0;
                        en_for_item2_next = 0;
                        en_for_item3_next = 0;
                    end
                2'd2:
                    if (amount_in_next - cost_It_2 >= 0) begin
                        req_amt = amount_in_next - cost_It_2; 
                        en_for_item2_next = 1;
                    end
                        else begin
                        en_for_item1_next = 0;
                        en_for_item2_next = 0;
                        en_for_item3_next = 0;
                    end
                2'd3:
                    if (amount_in_next - cost_It_3 >= 0) begin
                        req_amt = amount_in_next - cost_It_3; 
                        en_for_item3_next = 1;
                    end
                        else begin
                        en_for_item1_next = 0;
                        en_for_item2_next = 0;
                        en_for_item3_next = 0;
                    end
            endcase


        end